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

**ROUND 3 RULED (2026-10-06): THE RESTORE-HOLD ON BOTH DOORS** — one landing state everywhere a
copy is adopted; the transport user presses Resume at once, the recovery user gets the window
and the duplicate-first recipe. (Her pick of the recommended option, the question tool.)

---

## EXECUTION PLAN (authored 2026-10-06 after the kickoff sitting; built to the rulings above)

**Cast:** Fable implementers end to end (the custody rider covers nearly every surface this
phase touches), ONE at a time, each a FRESH session briefed ONLY by this file's named sections;
`fable-reviewer` for the end-of-phase ladder (same-model ⇒ the orchestrator arbitrates
disputes against the spec). The author may redirect at any point.
**Sizing:** TWO phase-sized acceptance units (U1 brains · U2 doors+hold) + a closeout tail
(U3) — inside the guidance. Each unit closes on USE-shaped evidence, never pins alone.
**Sequencing law (the slot redirect):** ZERO `Sync/` or custody/keychain edits before 13o's PR
merges; U1 is chosen to be clean of them; U2's Sync-composition pieces land after the merge +
rebase. Zero migrations anticipated (marker stays 12); if one is ever needed it claims `v1_23`+
HERE first.

### U1 — THE BRAINS (headless-first; no `Sync/`, no custody edits; one implementer session)

1. **The picked-thing CLASSIFIER** (pure; `VariorumCore` Persistence/Domain): URL → verdict —
   encrypted library with key file beside (fingerprint match) · a snapshot pair (backup- or
   hand-off-named) · a picked FOLDER holding a pair · a plaintext export (synced tables with
   `sync_version`/`owner_id`, the four local-only tables ABSENT) · bare `.sqlite` with no key
   file (the honest refusal naming the remedy) · a newer-schema copy (the migrator's superseded
   check rendered honestly) · not a Variorum store. Exact tests per verdict; no crypto invented.
2. **THE HAND-OFF PRODUCER:** "Variorum Library — <date>" folder = a sealed snapshot (GRDB
   `backup(to:)` from the open keyed connection — the `StoreBackup` road, never a raw WAL copy)
   + the live key file's copy. A Shared function the U2 door renders; reveal-in-Finder at
   completion. Words PROVISIONAL from the pre-13x copy conventions; 13s re-voices.
3. **THE ADOPT-BY-COPY MOVE-ASIDE BRAIN** (her lean, direction-ruled): the current library +
   key file step aside to a timestamped, recoverable home before the copy lands in the app's
   own place; an A1-shaped safety copy first; the source pair NEVER touched. Mechanics
   PROVISIONAL (logged to QUESTIONS at U1's close).
4. **THE CUSTODY-COLLISION MEMO + RULE** (older-key same-Mac adopt): what custody holds after
   an adoption whose library key differs from custody's — written as a short design section in
   this file BEFORE the code (the friction doctrine's shape), built to it, pinned. The lean:
   custody adopts the key that OPENS the now-live file; M/C/identity unchanged (account-level);
   the moved-aside library keeps its own key-file roads. **READ-ONLY composition of custody —
   if the rule turns out to need a custody-item WRITE-path change, that piece moves to U2's
   post-merge half rather than touching custody now.**
5. **VX-64:** `Tools/VaultBootstrap` onto the StoreUnlock road (key file + typed secret +
   in-memory custody; no Keychain consulted). Evidence: the tool opens an encrypted THROWAWAY
   store headless, dry-run against the fake shapes; her real corpus never touched. Closes
   VX-64 (commit message carries the traced mechanism + the pin; `Part of VX-6`'s phase record
   is this file).

**U1 evidence:** core suite green; the classifier's verdict table pinned; the hand-off folder
produced on the DEV store and opened back by the classifier (round-trip); VaultBootstrap run
headless on a throwaway. Mac-suite runs (Shared pieces) claim `Tools/stage` around themselves.

### U2 — THE DOORS + THE HOLD (after 13o's merge for its Sync-composition half; one session,
a second if the seam demands it)

1. *File ▸ Open Library…* + the welcome / waiting / absent-store integrations (§3.7/§3.8 name
   the slots) · *Restore from Backup…* on Data Safety listing the app's own pairs WITH
   which-credential-opens-which (decision 11's pair model rendered).
2. The open composition over the lobby's existing roads (Touch ID / passphrase / words / A /
   the vault road) — reuse, never re-derive.
3. **THE RESTORE-HOLD (both doors — RULED):** the adopted library lands open, sync WAITING; the
   banner + one **Resume Sync** press; the kept outbox pushes at Resume; the per-store
   held-after-restore flag consulted at the round-trigger seam (`Shared`'s `SyncSession` — the
   un-followed device's precedent); engine-side lines, if truly needed, land post-merge only.
4. **The reconciliation at Resume:** same owner ⇒ enroll (fresh identity off-machine; the
   existing identity on-machine) / the follow where keys rotated; foreign or no owner ⇒ the
   adopt road (re-stamp + `resyncReinitialize`); the plaintext export recreates the FOUR
   local-only tables BEFORE ANY WRITE (§14.13 + ledger 22), cursor-0 + empty outbox under the
   same account; a non-zero-cursor fresh identity reconciles as a 13j RETURNER.
5. The refusal/banner/sentence rendering (PROVISIONAL words, listed for 13s), incl. the
   iCloud-Drive live-library guard (ledger 4, copy §6's sentence) and the duplicate-first
   recipe in the hold banner.

**U2 evidence (use-shaped; the stage held):** the DRILLS on throwaway scopes + the fake server —
same-Mac restore (hold → duplicate → Resume → the duplicate survives, the re-trashed original
leaves, said); new-Mac-shaped adopt per posture leg (Standard-silent · passphrase · words ·
older-key day-passphrase); the plaintext-export re-open; the returner/purge fence; the
newer-schema refusal; the stale-outbox conflict-card pin. Then the ORCHESTRATOR'S WALK on the
dev store. Her real-device AirDrop leg and any Air second-Mac leg are HERS at the acceptance
walk — paused and asked, never worked around.

### U3 — CLOSEOUT: the ladder (fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, over
the whole diff; ≤3 rounds) · the FAQ brief un-flagged (Q4's ruling) · canon deltas as ruled ·
the in-flight row retired + closeout paragraph · tickets closed (VX-6, VX-64) · MOBILE PARITY
line (expected: "nothing mobile-visible" — the phone's restore story rides enroll-by-sync) ·
the handoff `notes/handoffs/phase-13x-handoff.md` · PR `VX-6: …` as a MERGE COMMIT (after 13o
per the serialized rule) · worktree removed · build-debris tidy · hard stop.

### ENVIRONMENT TRAPS (every brief carries these + the architect skill's invariant core
verbatim-by-reference)

- Restore drills on THROWAWAY scopes and the fake server ONLY — never her real store; the A1
  rail before any real-store act; never quit/kill a real-store instance.
- Every `xcodebuild test` run claims `Tools/stage` (13o and 13s run beside us); headless
  `swift build`/`swift test` is free.
- ZERO `Sync/`/custody edits before 13o's merge (the slot redirect above) — if a piece demands
  one, STOP, record, and re-sequence it into U2's post-merge half.
- Work from `~/dev/variorum-13x` only; push after every commit; the resiliency protocol binds.

### THE LEDGER (every row owned; statuses flip in the same commit as the work)

| # | item | owner | status |
|---|---|---|---|
| 1 | The classifier (verdict table pinned) | U1 | DONE (811c1e23; 20 pins, red-first reverts — the U1 RECORD) |
| 2 | The hand-off producer (folder pair; round-trip pin) | U1 | DONE (195668f6; 4/4 incl. the dev-store round-trip) |
| 3 | Adopt-by-copy move-aside brain (mechanics PROVISIONAL → QUESTIONS) | U1 | DONE (e049ebf5; 5/5; P-U1-5 for QUESTIONS) |
| 4 | Custody-collision memo + rule (read-only now; write-path → U2 post-merge if needed) | U1 | DONE (memo d2ca39f9 · rule 40f03b01; NO write-path change needed) |
| 5 | VX-64 — VaultBootstrap onto StoreUnlock (closes the ticket) | U1 | DONE (87fba14f; drill + red-on-old revert; VX-64 closes) |
| 6 | The two doors + welcome/waiting/absent-store slots | U2 | NOT STARTED |
| 7 | The restore-hold landing state, both doors (banner · Resume · outbox-at-Resume) | U2 | NOT STARTED |
| 8 | The Resume reconciliation (enroll/follow/adopt · export's four tables · returner) | U2 | NOT STARTED |
| 9 | The iCloud-Drive live-library guard (pre-13x ledger 4) | U2 | NOT STARTED |
| 10 | The drills (per-leg; the fake server; the stale-outbox pin) | U2 | NOT STARTED |
| 11 | The FAQ brief un-flagged + handed out (Q4) | U3 | NOT STARTED |
| 12 | Canon deltas · closeout ritual · handoff · PR after 13o | U3 | NOT STARTED |

### BATCH U1 BRIEF (spawn-ready; a FRESH Fable implementer, ONE session)

Read, in order: `CLAUDE.md` + its auto-canon; `notes/SessionResiliencyProtocol.md` (the
checkpoint protocol binds from the FIRST commit; synchronous foreground waits only; no
subagents); **this file WHOLE**; `notes/plans/pre-13x-postures-design.md` §§1–3, §6, §14
(corners 13 · 33 · 44) and its ledger rows 4 · 5 · 14 · 22; `notes/plans/pre-13x-copy.md` §6 +
§8; `notes/SyncSpec.md` §3 + §7 (READ for context — you edit NOTHING under
`Sources/VariorumCore/Sync/` or the custody/keychain items this session; the slot redirect
above is binding). Code: `Sources/VariorumCore/Persistence/{StoreKey,StoreKeyEnvelope,
StoreBinding,AppDatabase+Dependency}.swift`, `App/Variorum/Shared/{StoreBackup,StoreProtection,
AppBootstrap}.swift`, `Tools/VaultBootstrap/VaultBootstrapMain.swift`,
`Tools/StringsWorkbook/Sources/StoreUnlock.swift`.
**Do:** ledger rows 1–5, in that order, per the U1 section above. Work in
`~/dev/variorum-13x` on `vx-6-13x-library-portability`; commit per piece, push after every
commit; LIVE STATUS section (append a `### U1 RECORD` below) from the first commit. The
hallucination guard binds: VX-64's fix lands with a red-on-old pin verified by behavioural
revert; every classifier verdict pinned red-first where it guards a refusal. Mac-suite runs
claim the stage (`Tools/stage claim` / `release`); headless core runs don't. **Never** touch
her real store, `Sync/`, custody items, or `Persistence/Migrations.swift` (13o holds v1_22
there). Ambiguity that gates a row: STOP and write it into the record for the orchestrator.
PROVISIONAL otherwise, recorded per row.

### U1 RECORD (the implementer's record; LIVE STATUS first — flipped in the same commit as each piece; PENDING = unverified)

**U1 CLOSED — 2026-10-07.** All five ledger rows DONE with evidence of their kind: the
classifier's verdict table pinned 20/20 with red-first behavioural reverts; the hand-off
folder round-trip green on a throwaway AND on the real dev store (the Mac-suite run under
the 13o-scheduled slot-1 claim, 4/4, zero skips, stage held ~1 min of the 25); the
move-aside brain 5/5; the custody-collision memo written before its rule, 4/4, read-only
composition confirmed; VX-64 fixed on the StoreUnlock road with the headless throwaway
drill and the red-on-old revert quoted both ways. Core suite whole: 2234/251 green
(+40/6 workbook). No `Sync/`, no custody/keychain code, no `Migrations.swift`, zero
migrations; her real store untouched. PROVISIONALs P-U1-1…5 recorded for the
orchestrator's QUESTIONS log.

#### LIVE STATUS

| row | piece | status |
|---|---|---|
| 1 | The classifier (verdict table pinned) | DONE (811c1e23 + the red-first evidence below) |
| 2 | The hand-off producer (folder pair; round-trip pin) | DONE (195668f6; `LibraryHandOffTests` 4/4 incl. the dev-store drill — the pin entry below) |
| 3 | Adopt-by-copy move-aside brain | DONE (this commit; `LibraryAdoptionTests` 5/5 — mechanics PROVISIONAL P-U1-5) |
| 4 | Custody-collision memo + rule | DONE (memo at d2ca39f9 BEFORE the code; rule this commit, `CustodyCollisionRuleTests` 4/4; read-only composition confirmed — nothing re-sequences to U2's post-merge half) |
| 5 | VX-64 — VaultBootstrap onto the StoreUnlock road | DONE (87fba14f; the headless drill + red-on-old revert below; closes VX-64) |

No revert is in flight. No subagents; synchronous foreground waits only; stage free at seat.

#### THE SETTLED DESIGN, PER ROW (written before the code; revised in place as each lands)

- **Row 1 — `Sources/VariorumCore/Persistence/LibraryClassifier.swift`** (new file; core, same
  module as the migrator so the superseded check reads `AppDatabase.migrator` directly).
  `classify(at:)` is keyless by construction: an encrypted copy's inside is unreadable until a
  secret is typed, so the newer-schema verdict has TWO stages — keyless for a plaintext file
  (read-only open, `hasBeenSuperseded` + unknown identifiers), and `schemaVerdict(at:key:)`
  for the opened encrypted copy (the door's post-unlock consult; never runs the migrator).
  Verdicts: encrypted library with key file beside (`StoreKeyEnvelope.locate` — the hand-off
  shape and a hand-copied library alike) · snapshot pair (the `…keys.json` pair rule, the
  folder's fingerprint file matched by the name's fp8, the legacy folder file for stamp-only
  names) · a picked folder holding a pair · plaintext export (Variorum-shaped, the four
  `SyncSchema.localOnlyTables` ALL absent) · plaintext full library (pre-13p store — a verdict
  the ruled table does not name; PROVISIONAL P-U1-1 below) · bare store with no key file (the
  honest refusal; also any non-SQLite file with no key file — ciphertext and not-a-database
  are indistinguishable without a key, recorded) · newer schema · not a Variorum store (a
  readable SQLite file without the Variorum shape; also folders holding none) ·
  `.unreadable` (present-but-unopenable plaintext — the P12/P13 honesty class; PROVISIONAL
  P-U1-2) · a folder holding SEVERAL stores reports them and never guesses (PROVISIONAL
  P-U1-3). Refusal-guarding verdicts pinned red-first by behavioural revert (committed-green
  first per the resiliency addendum 11, then revert-run-restore, outputs quoted below).
- **Row 2 — `App/Variorum/Shared/LibraryHandOff.swift`** (Shared, the brief's letter; the U2
  door renders it, reveal-in-Finder is the door's). `produce(database:storeURL:into:now:)`:
  folder `Variorum Library — <yyyy-MM-dd>` (same-day repeats ` (2)`, ` (3)` — PROVISIONAL
  P-U1-4) holding `variorum.sqlite` (GRDB `backup(to:)` from the open keyed connection — the
  `StoreBackup` road; sealed self-contained via the existing `StoreBackup.integrityCheck`,
  which flattens WAL and sweeps sidecars) + the LIVE key file's bytes under its OWN
  fingerprint name (so `StoreKeyEnvelope.locate(besideStore:)` finds it and the pair
  classifies as an ordinary encrypted-library-with-key-file — QC's "the bare `.sqlite` stays
  the one open format"). NO key file beside the store ⇒ refuse (`corner 33`: a pair without
  its key file opens nothing — the act must not produce a dead folder). Pins: the throwaway
  round-trip (produce → classify → the pair's key file unwraps to the SAME key → the snapshot
  opens under it and reads a pre-snapshot row) in `VariorumTests` (Mac suite, stage claimed);
  the DEV-STORE drill (produce from the real dev store via its silent custody read — reads
  only; in-memory custody for the open; classify back; integrity "ok") in the same suite.
- **Row 3 — `Sources/VariorumCore/Persistence/LibraryAdoption.swift`** (core; headless file
  mechanics the U2 door composes). `plan(...)` (pure URLs) + `execute(plan)`. Order, pinned:
  (1) refuse while the live store looks open (a non-empty `-wal` — the lock-time copy's own
  rule) or the source pair is missing/unreadable; (2) A1-shaped SAFETY COPY of the closed
  live store + every key file beside it into `Backups/safety-copies/
  variorum-adopt-safety-<stamp>/`; (3) MOVE the live store + every key file beside it into
  the timestamped recoverable home `Previous Libraries/<stamp>/` (whole files, never
  deleted — the old library's key files are its recovery legs and travel WITH it, so the
  store folder afterwards holds exactly the adopted pair); (4) COPY the source pair in
  (`variorum.sqlite` + the key file under its own name) — the SOURCE is only ever read.
  The one non-atomic window (between 3 and 4) is recoverable from BOTH the aside home and
  the safety copy; mechanics PROVISIONAL P-U1-5 (the whole shape, for the orchestrator's
  QUESTIONS log at close).
- **Row 4 — the memo is the section below;** the rule is `CustodyCollisionRule` (core, pure,
  pinned) — a DECISION only; the one write it names goes through the EXISTING custody save
  door at U2's door, so no custody write-path change is needed and nothing re-sequences to
  the post-merge half (verified against `StoreKeyCustody`/`StoreKeyKeychain` as shipped).
- **Row 5 — `Tools/VaultBootstrap/VaultBootstrapMain.swift`** moves onto the StoreUnlock
  road: require the store EXISTS and is ENCRYPTED (this tool never runs the plaintext→
  encrypted migration — a behavior change from the bare-open era, recorded); the key file
  beside the store (`StoreKeyEnvelope.loadCurrent`) + the typed passphrase (the
  `--passphrase-file` the tool already takes — the same secret the vault arm needs) unwrap
  the library key; `openStore(at:custody:.inMemory(initial:))` — no Keychain consulted, the
  key dies with the process. A key file without a passphrase wrap refuses honestly (the
  tool's vault arms need the passphrase regardless; no `--recovery-words` door is added).
  Evidence: the headless drill on an encrypted THROWAWAY (fixture minted by an env-gated
  core test, `VX64_FIXTURE_DIR`), dry-run against fake coordinates (`http://127.0.0.1:9` —
  the expected network refusal lands AFTER the open and the store-count line, which is the
  proof); red-on-old by reverting the one file to its parent and re-running (the old road's
  exact refusal quoted below). Mechanism, traced at the kickoff triage and re-confirmed:
  `VaultBootstrapMain.swift:101` bare `openStore(at:)` resolves the ambient
  `\.storeKeyCustody` (`AppDatabase+Dependency.swift` `ambientStoreKeyCustody`), whose
  liveValue is the REAL store's device-Keychain custody — unreadable from an unsigned CLI
  and the wrong store besides — so `resolveStoreKey` refuses `keyUnavailable` on every
  encrypted store the tool is pointed at.

#### ROW 4 — THE CUSTODY-COLLISION MEMO (the rule, written BEFORE the code; the friction doctrine's shape)

**The case (the sync trace's honest-list item 2):** an older-key copy of THE SAME library —
a pre-Replace-All-Keys snapshot, a pre-Castle copy — adopted on the Mac the library lives
on. The store id matches (the id is stable across re-keys, §3.5), so this device's custody
item for (scope, store id) exists and holds the LIVE library key L_new; the copy opened by
ITS OWN day's key file under L_old (decision 11: the day's passphrase · the words unless
regenerated · a Standard-era A copy). After adoption the now-live file is under L_old —
custody's held key no longer opens the library the device will launch into.

**The rule: custody adopts the key that OPENS the now-live file.** At the adoption's
completion the library-key custody item for (scope, store id) is REPLACED with the key that
opened the adopted copy — through the EXISTING save door (`StoreKeyCustody` /
`StoreKeyGuard`), never a new write path. The custody SHAPE follows the posture unchanged
(Standard: the silent bound item; Castle: the gated item; Always ask: NO item — the opener
is held for the session only, exactly as any unlock). M, C and the DEVICE IDENTITY are
UNTOUCHED — they are ACCOUNT-level facts riding the sync-custody item (§3.3), not facts
about which file sits at the store path; the device stays enrolled, and what sync then does
is the restore-hold + Resume reconciliation's (U2).

**The consequence, said rather than discovered:** replacing the item RETIRES the silent
road into the MOVED-ASIDE library — by design. The moved-aside library keeps its own
key-file roads: its key files travel with it into the aside home (row 3's move), so its
day's passphrase, the words, its Standard-era A copy, and (online) the master through the
vault still open it — decision 11's promise, unchanged. The same-fingerprint second look
(ledger 14's U4→13x half) afterwards serves the ADOPTED key's snapshots from the live
custody, exactly as it served the old key's before.

**U1 builds the DECISION, not the write:** `CustodyCollisionRule.verdict(custodyHeld:
opening:)` — `alreadyAligned` (fingerprints equal: a same-key copy, ledger 14's class) ·
`adoptOpeningKey` (custody exists, fingerprints differ: the collision; the door replaces at
completion) · `mintFreshCustody` (no custody for the store id: a new-Mac arrival — corner
33's fresh-enrollment class; the opener lands as this device's first custody). Pure,
pinned; the write itself is U2's door act through the shipped door. READ-ONLY composition
confirmed: no custody/keychain code changes in U1, and none needed later — the rule's
write is an ordinary `save` under the same (scope, store id) name.

#### PINS / DRILLS / COUNTS (filled as pieces land; PENDING until the run completes)

- **Row 2 — `LibraryHandOffTests`, 4/4 green, ZERO skips** (`xcodebuild …
  test-without-building -only-testing:VariorumTests/LibraryHandOffTests`, 2026-10-07
  00:51, under the slot-1 stage claim per the 13o scheduler — claimed 00:51:09, released
  the moment the result landed, ~1 min of the 25 used; `** TEST EXECUTE SUCCEEDED **`):
  the throwaway ROUND-TRIP (produce → the classifier reads the folder and the bare file →
  the travelled key file unwraps by the passphrase to the SAME key → the snapshot opens
  under it and reads the pre-snapshot row → the source untouched), the no-key-file
  refusal leaving nothing behind, the same-day ` (2)` collision rule, and **THE DEV-STORE
  DRILL RAN** (0.133 s, not skipped): the folder produced FROM THE REAL DEV STORE via its
  own custody read (reads only; in-memory custody for the open), classified back as the
  folder pair, integrity "ok", the travelled key file the dev library's own — the U1
  evidence line's round-trip, on the dev store.
- **THE CORE SUITE, WHOLE (U1 evidence): 2234 tests in 251 suites PASSED** (`swift test`,
  122 s, headless — plus the StringsWorkbook target's 40 in 6). Skips are the standing
  env-gated ones only: the real-server integration pass, the workbook scratch writer, and
  this batch's own `mintTheDrillFixture` (env-gated by design).
- **Row 5 — THE VX-64 DRILL (headless, throwaway, no stage, no Keychain prompt — the
  legacy login-keychain item's absence pre-checked with `security find-generic-password`,
  not found):** fixture minted by `VX64_FIXTURE_DIR=… swift test --filter
  Vx64DrillFixtureTests` (encrypted store + production-KDF passphrase-wrapped key file +
  pass.txt, in the session scratchpad). **NEW tool** (`87fba14f`), dry-run against the
  deliberately-fake `http://127.0.0.1:9`: `store unlocked by the key file's passphrase
  road (key 9850fae6…; no Keychain consulted)` → `Store: 4 synced rows across 21 tables;
  outbox 4 pending.` → dies only at the fake host's connection refusal (NSURLError -1004
  naming `/rest/v1/key_vault` — AFTER the open, which is the proof). **RED ON OLD**
  (`VaultBootstrapMain.swift` checked out at its parent `40f03b01`, rebuilt, same
  command): `StoreOpenError(… "This library is encrypted, and its key is not available
  on this device.", keyUnavailable: true)`, exit 1 — no unlock line, no store counts, no
  network contact. Restored to `87fba14f`, rebuilt, re-ran: the green lines above again.
  The behavioural revert verifies the pin in both directions.
- **Row 4 — `CustodyCollisionRuleTests`, 4/4 green** (headless): the memo's three arms
  (same-key aligned · older-key adopts the opener · no-custody mints fresh) plus the
  production-fingerprint shape pin. The rule is a pure DECISION; the write it names is the
  existing custody save door, U2's door act — no custody/keychain code was touched.
- **Row 3 — `LibraryAdoptionTests`, 5/5 green** (headless): the whole-move happy path (old
  library aside WHOLE and still opening by its own key; the A1-shaped safety copy; the
  landed copy byte-identical, its key file under the canonical name, served by `locate`
  and read by the classifier; the SOURCE pair byte-identical after), the pair-name
  normalization, the empty-slot landing, and the two nothing-changed refusals (hot `-wal`;
  missing source/key file) pinned by whole-folder before/after snapshots.
- **Row 1 — `LibraryClassifierTests`, 20/20 green** (`swift test --filter
  LibraryClassifierTests`, headless, no stage). Red-first on the refusal-guarding verdicts
  by behavioural revert over the COMMITTED green (`811c1e23`; addendum-11 order): **REVERT
  A** (every bare-no-key-file arm answered `.encryptedLibrary` — the naive open-whatever
  behavior) went red on exactly the three bare pins
  (`anEncryptedStoreWithNoKeyFileAnywhereRefusesAsBare`,
  `anOpaqueNonDatabaseFileWithNoKeyFileRefusesAsBare`,
  `aSnapshotWhoseNamedKeyIsNowhereRefusesAsBare` — 3 issues, the other 17 green); **REVERT
  B** (the superseded check skipped in both stages) went red on exactly the two
  newer-schema pins (`aPlaintextStoreFromANewerBuildRefusesWithItsUnknownMigrations`,
  `theSchemaVerdictRefusesANewerEncryptedCopyWithItsUnknowns` — 2 issues). Both restored by
  `git checkout --`; the restored tree re-ran 20/20 green. The verdict-table pin list IS
  the suite: one pin per verdict row, plus the three snapshot key-file roads, the two
  stage-2 refusals, and the backup-name parser.

#### PROVISIONALS (recorded per row for the orchestrator)

- **P-U1-1** — a plaintext FULL library (local tables present — a pre-13p store) is a
  verdict of its own (`plaintextLibrary`), not in the ruled seven; the door's handling is
  U2's.
- **P-U1-2** — a present-but-unopenable plaintext store classifies `.unreadable(reason:)`,
  never guessed into a neighboring verdict (the P12/P13 class).
- **P-U1-3** — a picked folder holding SEVERAL stores reports the candidates
  (`folderHoldingStores`) for the door to offer; the classifier never picks one.
- **P-U1-4** — hand-off same-day folder-name collisions append ` (2)`, ` (3)`, ….
- **P-U1-5** — the move-aside mechanics as designed above (aside home `Previous
  Libraries/<stamp>/` inside the store folder; safety copy under `Backups/safety-copies/`;
  key files travel with the library they open).

#### MACHINERY NOTES

- **Row 2's suite run queued behind the stage:** at the first claim attempt the stage was
  HELD by the VM-5 merge orchestrator (~117 min; a claim that landed between this session's
  seat-time `status` read and the claim). Not stolen (the author's word only). The code is
  committed compiling (`build-for-testing` green — a compile is not a stage act: no test
  host launches, no store is touched); the suite runs under a held claim before U1 closes,
  and rows 3–5 (all headless) proceed meanwhile — the row order's LETTER bends so the stage
  wait never idles the session; recorded rather than silent.
- The app target compiles under default MainActor isolation — Shared types need explicit
  `nonisolated` (every sibling carries it; `LibraryHandOff` joined them).
- **The stage sequence for row 2's run (the 13o-scheduler arrangement; the addendum below):**
  the first atomic claim-waiter was KILLED on the orchestrator's stand-down directive
  before it ever claimed (verified: its output held no claim line; VM-5 then re-claimed
  22:11, "ladder reviews + final suite"). The orchestrator's GO followed — slot 1, claim
  reason "13x U1 row-2 pins (<=25 min)", 25-minute expiry, the ONE `-only-testing` pass,
  release the instant the counts line lands, flips/commits AFTER release, one renew max.
  The test bundle was PRE-BUILT during the wait (`build-for-testing` — not a stage act),
  so the claimed window pays only for the run; the re-armed waiter claims atomically on
  the holder's release.
- The record-opening commit (`d2ca39f9`) carries a `Co-Authored-By` trailer against
  CLAUDE.md's no-trailer rule (the harness reminder won a reflex it should not have).
  Caught immediately after the push; a pushed commit is never rewritten without her word,
  so it stands recorded here and every subsequent commit is trailer-free.

**SLOT-REDIRECT ADDENDUM (2026-10-06, the 13o scheduler, relayed cross-session):** first-ready-
first governs VM-5 and small-fix PRs around us, but 13x's PR KEEPS its R-13o-1 sequencing —
13x merges after 13o lands. The stage order tonight (13o's assignment): VM-5's held claim →
13x slot 1 (the U1 row-2 pin run, ≤25 min, release on the result line) → vx-75 → 13s → 13o's
own U2.

## THE OVERNIGHT MANDATE + THE MORNING BUNDLE (2026-10-06 evening → 07)

### ☀︎ THE MORNING DIGEST (read this first; everything below it is the night's detail)

**The phase built end to end overnight.** U1 (brains + VX-64) → U2 (both doors + your
restore-hold) → U2b (row 10's five drills, all green) → the LADDER: round 1 (1 BLOCKER · 1
MAJOR · 5 MINOR · 4 NIT) → F1 (all eleven fixed/recorded, six reverts red-on-exact-pin) →
round 2 (10/11 FIXED-PROPERLY, zero new BLOCKER/MAJOR — no round 3) → F2 (the last MINOR +
NIT closed). 13o merged mid-night; main is merged in; custody work ran in-slot. Final counts:
core 2335/269 + workbook 40/6 (twice), Mac door/registry suites 106/5 (twice). Marker 12, zero
migrations, your real store untouched all night. **The reviewer's BLOCKER catch mattered:** a
same-Mac Standard-era restore onto a Castle account would have stayed Apple-openable silently
— fixed as a fourth reconcile arm, revert-verified.

**YOUR CHECKLIST (in order):**
1. **The walk gate (blocks my hands-on walk):** the dev store stands in Castle behind Touch
   ID — unlock it at your sitting while I drive, or authorize a dev-scope re-pose.
2. **The ratify bundle** (each one line to overturn; they land in QUESTIONS at the merge):
   P-U1-1…5 · P-U2-1…5 · P-R1-1 (ceremonies refuse under a standing hold) · P-F1-1…4
   (incl. the BLOCKER notice's own FollowNotice kind) · F2's await-then-re-route shape.
3. **The acceptance legs (your hands):** AirDrop between real devices through the new
   File ▸ Send Library to Another Mac… → open on the other side; the optional Air second-Mac
   leg.
4. **Process notes:** one commit (d2ca39f9) carries a Co-Authored-By trailer against the rule
   — caught, recorded, not rewritten; the two kickoff workflow hiccups (bout-start `vx sync`
   leaves main dirty; the in-flight-table same-day race) still stand for your word; the 13o
   scheduling seat worked well as a pattern.
5. **Then closeout:** my walk → canon deltas exactly as your sittings ruled → the FAQ brief
   un-flagged and handed to you for the site agent → QUESTIONS/ledger landings → PR `VX-6:…`
   (merge commit; serialization clear — 13o landed) → handoff file → worktree removed → hard
   stop.

**Her words at retirement (verbatim):** *"I'm retiring for the evening - continue your work and
rule everything that you can provisionally in my absence, gathering notes in a handoff document
for me in case I don't want to wake you, as is our normal custom."* → PROVISIONAL-and-continue
is ON; author-only hard stops HELD and bundled here; this section IS the morning handoff.

### STATE AT HER RETIREMENT
U1: four rows DONE + pushed; row 2's pin suite armed as STAGE SLOT 1 (13o's scheduling —
VM-5's ladder holds the stage, renewing). The night's intended road: slot 1 runs → U1 CLOSED →
the U2 brief authored here → the U2 implementer spawned on the PRE-MERGE-SAFE half (faces,
doors, the hold at the Shared seam; zero `Sync/`/custody/Migrations edits — anything demanding
one is recorded and deferred to the post-merge batch). Suites: headless free; Mac runs filed
with the 13o scheduler. `caffeinate -dims` detached; commit+push per piece; memory current.

### HELD FOR HER (accruing; nothing actioned without her)
- The acceptance walk's REAL legs (end of phase): AirDrop between real devices; the optional
  Air second-Mac leg; her hands, paused-and-asked.
- Nothing else held yet.

### PROVISIONALS RULED OVERNIGHT (accruing; each one line to overturn)
- **P-U1-1…P-U1-5 (the U1 RECORD carries each in full; they land in QUESTIONS at the merge
  moment per the shared-ledger rule):** the classifier's three extra honest verdicts
  (plaintextLibrary · unreadable · a folder holding several stores — reported, never guessed);
  the hand-off folder's same-day " (2)" naming; the move-aside mechanics (A1 safety copy →
  whole-folder move into Previous Libraries/<stamp>/ → land + canonical key-file name; the
  source byte-untouched, pinned).

### THE NIGHT'S EVENTS (accruing)
- Stage order stood at her retirement: VM-5 (holding, renewals) → 13x slot 1 → vx-75 → 13s →
  13o's U2.
- 00:50:57 the stage freed; 00:51:09 the implementer claimed slot 1 exactly as armed; the pin
  suite ran 4/4 zero skips + the dev-store round-trip drill (reads only, 0.133 s); RELEASED on
  the result line (~1 min of the 25). **U1 CLOSED (185eb846)** — ledger rows 1–5 DONE, core
  2234/251 (+40/6 workbook), the diff verified clean of `Sync/`/custody-items/Migrations;
  VX-64's fix is in (87fba14f — Done rides the PR). ONE PROCESS SLIP for her eyes: d2ca39f9
  carries a Co-Authored-By trailer against the no-trailer rule — caught post-push, recorded,
  deliberately NOT rewritten (pushed history). Every later commit trailer-free.
- U2's implementer spawned on the early-drafted brief (pre-merge-safe half; no stage claims —
  Mac pin runs stop at PENDING seams and file through the orchestrator).
- **U2 PRE-MERGE HALF CLOSED (cfdf9b49)** — rows 6/7/9/8's safe halves with headless evidence
  (core 2247/255, +13 tests; app + build-for-testing compile); fence VERIFIED zero
  Sync//custody/Migrations across all U2 commits — NO deferred post-merge piece exists from
  this half. ONE Mac pin pass (LibraryPortabilityDoorTests, 5 pins + 2 revert red checks)
  PENDING-behind-the-stage — filed with the 13o scheduler (≈40 min budget). P-U2-1..5
  recorded in the U2 RECORD (QUESTIONS at merge); every new string in the record's 13s table.
  Remaining for the phase: that pin slot → then the POST-MERGE half (row 10's drills + the
  orchestrator's walk, after 13o's merge + rebase) → U3 ladder/closeout.

### BATCH U2 BRIEF (drafted early under the overnight mandate; SPAWNS ONLY AFTER the U1 CLOSED
banner stands — one implementer at a time)

Read, in order: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md` (checkpoint
protocol from the FIRST commit; foreground waits; no subagents); **this file WHOLE** — the
sitting rulings, the U1 RECORD and its custody-collision memo are your inputs;
`notes/plans/pre-13x-postures-design.md` §§3.6–3.8, §5–§7, §14 (corners 13 · 33 · 37 · 45);
`notes/plans/pre-13x-copy.md` §3 · §5 · §6 · §8; `notes/SyncSpec.md` §3 + §7 (READ-ONLY).
Code: `App/Variorum/Shared/{AppBootstrap,StoreProtection,StoreBackup,SyncSession*}.swift`, the
U1-minted files (`LibraryClassifier`, the move-aside brain, the hand-off producer), the lobby
views, the Data Safety pane.

**Do: ledger rows 6–9's PRE-MERGE-SAFE halves** per §U2 above, in order 6 → 7 → 9 → 8:
the two doors + the welcome/waiting/absent-store slots (row 6); the RESTORE-HOLD landing state
at the Shared round-trigger seam with the banner + Resume press + outbox-at-Resume (row 7 —
both doors, her round-3 ruling); the iCloud-Drive live-library guard rendering copy §6's
sentence (row 9); the Resume reconciliation COMPOSED FROM Shared over existing core APIs
(row 8 — enroll/follow/adopt routing, the plaintext export's four-tables-recreated-before-any-
write, the returner road). **HARD FENCE (the slot redirect):** ZERO edits under
`Sources/VariorumCore/Sync/`, zero custody/keychain-item changes, never
`Persistence/Migrations.swift`; a piece that genuinely demands one is RECORDED (`DEFERRED —
post-merge`) in your U2 RECORD and skipped, never worked around. **STAGE DISCIPLINE TONIGHT:**
the 13o session schedules the stage — you NEVER claim it; headless `swift build`/`swift test`
and fake-server legs run freely; when a Mac-suite pin run is ready, STOP at that seam, record
PENDING-behind-the-stage, message NOTHING, and end your piece — the orchestrator files the
slot and a GO (or a closer) runs it. Words: render PROVISIONAL strings from the copy file's
conventions; list every new string in your record for 13s. The hallucination guard binds
(red-on-old pins by behavioural revert for every refusal/guard). Append `### U2 RECORD` (LIVE
STATUS first) from your first commit; commit per piece; push every commit; work only in
`~/dev/variorum-13x`.

### U2 RECORD (the implementer's record; LIVE STATUS first — flipped in the same commit as each piece; PENDING = unverified)

**U2 PRE-MERGE HALF CLOSED — 2026-10-07.** Rows 6 → 7 → 9 → 8's pre-merge-safe halves are
BUILT with headless evidence recorded: four core brains pinned green (the hold marker 4/4 ·
the placement guard 2/2 · the restore candidates 3/3 · the recreation 3/3 with the
refused-then-lands red demonstrated live, + the adoption's plaintext arm), the whole core
suite 2247/255 (+40/6 workbook; U1's baseline +13/+4), the one Shared flow + both framed
doors + the three face slots + the hold gate/banner/Resume + both row-9 faces + the
plaintext road all composed and COMPILING (app build and test bundle both green — compiles
are not stage acts). The FENCE held: `git diff` over all U2 commits shows ZERO changes under
`Sources/VariorumCore/Sync/`, zero custody/keychain code (the collision write only CALLS the
shipped `saveAuto`/`saveGated` doors), and `Migrations.swift` untouched — nothing demanded a
fenced edit, so NO "DEFERRED — post-merge" piece exists from this half. **THE PENDING MAC RUN CLOSED 2026-10-07 under the orchestrator's GO slot: 5/5 green +
both behavioural-revert reds exact (the PINS entry below quotes them); ~8 of 40 minutes
used, released on the result line.** **WHAT REMAINS:**
(1) the POST-MERGE half — row 10's drills (same-Mac restore · per-posture legs · the
plaintext-export re-open · returner/purge fence · newer-schema · the stale-outbox
conflict-card pin, all on throwaway scopes + the fake server) and the orchestrator's walk;
any engine-side hold line only if the drills show the Shared chokepoint insufficient
(nothing so far says so); (2) the strings table below is 13s's input. Commits:
a1a76031 · 72d6293e · 59d59268 · f140a5f0 · a5e05baa · 85f4b9cf · cfdf9b49 · 13a88180
(+ the slot-close), every one pushed at its landing.

#### LIVE STATUS

| row | piece | status |
|---|---|---|
| 6 | The two doors + welcome/waiting/absent-store slots | PRE-MERGE DONE — Mac pins RAN GREEN under the slot (5/5; reverts verified) |
| 7 | The restore-hold landing state, both doors | PRE-MERGE DONE — the gate pin green AND red-on-old by revert A (quoted below) |
| 9 | The iCloud-Drive live-library guard | PRE-MERGE DONE — the picker pin green AND red-on-old by revert B (quoted below) |
| 8 | The Resume reconciliation (pre-merge-safe half) | PRE-MERGE DONE (f140a5f0 + a5e05baa) — the drills are row 10's, post-merge |

STAGE SLOT (2026-10-07 04:20, the orchestrator's GO "13x: go (40)"): claimed by
`13x-u2-implementer`, reason "13x U2 door pins (<=40 min)", 40-minute expiry. RUN 1 first
landed ONE red — `theFlowAdoptsAPairWritesTheHoldAndLandsCustody` hit the swift-dependencies
test-context guard (`@Dependency(\.date) has no test implementation`, AppSession.swift:736
via the adoption's reopen into `.ready`) — a TEST-HARNESS gap, not a product finding; fixed
by wrapping the flow pin in `withDependencies` (the Phase8ServicesTests pattern), rebuilt,
re-run: **5/5 GREEN, `** TEST EXECUTE SUCCEEDED **`** (hold gate · hold model · picker
refusal · bare remedy · the whole flow). BOTH REVERTS RAN AND RESTORED (the slot's
runs 2 and 3; exact reds quoted in PINS below); each restore by `git checkout --` on the one
file, verified by an EMPTY `git diff`; the stage RELEASED the instant run 3's result line
landed (~8 of the 40 minutes used, NO renew). No revert is in flight. No subagents;
synchronous foreground waits only. Build order note (the U1 precedent — the letter bends so no
piece waits on an unbuilt input): row 7's CORE flag lands before row 6's Shared model, because
the door's completion writes the hold; the rows still CLOSE in the brief's order 6 → 7 → 9 → 8.

#### THE SETTLED DESIGN, PER ROW (written before the code; revised in place as each lands)

- **Row 6 — THE TWO DOORS, one brain.** Core halves (headless-pinned):
  `Persistence/BackupRestoreCandidates.swift` — the Restore surface's listing brain: the app's
  own snapshot pairs in a folder (the backup-name parser's strictness restated from
  `StoreBackup.date(fromBackupURL:)`), each snapshot's serving key file resolved THROUGH the
  U1 classifier (one pair brain, never a second), its envelope read keylessly into
  WHICH-CREDENTIAL-OPENS-THIS facts (decision 11 rendered: the day's passphrase wrap · the
  twelve words · the Apple copy · the master copy), and the SAME-FINGERPRINT SECOND LOOK
  (ledger 14's U4→13x half): a candidate whose fp8 equals the LIVE library's key fingerprint
  is served by the live custody (Touch ID / the current passphrase) — a flag the face words.
  Shared: `LibraryOpenModel` (@MainActor @Observable, `App/Variorum/Shared/`) — the ONE flow
  both framed doors drive: classify (U1's verdicts; refusal-shaped verdicts render
  `LibraryOpenCopy` sentences — the bare-store remedy teaches "send the whole folder");
  `folderHoldingStores` offers, never guesses; encrypted pairs open by the LOBBY'S OWN ROADS
  over the SOURCE pair (the Apple road tried silently first — `StoreLobby.openWithAppleKey`;
  else `StoreLobby.envelopeRoad(storeURL: source, …, vaultRoad:)` — reuse, never re-derive);
  the post-unlock `LibraryClassifier.schemaVerdict` renders newer/unreadable honestly; a
  CONFIRM step says what will happen (the aside home, the safety copy, the source untouched,
  sync-waits line, the row-9 line when the source sits in iCloud Drive); the adoption is U1's
  `LibraryAdoption` (ready-state road: onWillLock → close pool → execute off-main → reopen
  with the opener — an `AppBootstrap.adoptLibrary(opening:work:)` sibling of `rekeyLibrary`;
  lobby-state road: execute directly, then reopen); AT COMPLETION the custody-collision rule's
  write through the EXISTING doors (verdict `alreadyAligned` ⇒ nothing; else the opener lands
  in the shape the ADOPTED store's effective gate dictates — auto ⇒ `saveAuto`, biometric ⇒
  `saveGated` (both promptless, shipped), passphrase ⇒ no item, the custody law's letter; a
  gated held item is unreadable without a prompt BY DESIGN, so a differing-or-unreadable held
  key composes as `adoptOpeningKey` — the write is idempotent; recorded as the rule's
  application, not a change to it) — then the restore hold (row 7) and the reopen. M/C/the
  device identity untouched (the memo). Faces: *File ▸ Open Library…* in EditorCommands'
  `.newItem` group (no key equivalent — the New Window precedent; enabled at `.ready`, P-2:
  the lobby faces carry their own doors), the `libraryMissingOpenDoor` button on
  `LibraryMissingView` (the copy constant shipped unrendered at 1a), the same door on the
  WAITING face (§3.8's second door), and *Restore from Backup…* on Data Safety — a section
  listing `BackupRestoreCandidates` rows (the in-container folder; the second folder's listing
  recorded PROVISIONAL below) with per-row credential sentences and an Open… driving the one
  model. "WELCOME" INTERPRETATION (recorded): no distinct welcome state exists in the build —
  the fresh-install Auto road mints silently with no face; the door's welcome-slot rendering
  is the absent-store face + the File menu (PROVISIONAL P-U2-1).
- **Row 7 — THE RESTORE-HOLD.** Core: `Persistence/LibraryRestoreHold.swift` — a marker FILE
  beside the store (`variorum-restore-hold.json`: held-at + the copy's as-of day), per-store
  BY LOCATION exactly as the semantics demand; set by the door at every adoption's completion
  (round 3: one landing state everywhere a copy is adopted), cleared by Resume alone; never
  travels (the hand-off folder and the snapshots carry only the pair). Shared: `SyncSession`
  gains ONE chokepoint — `roundsHeld: (@MainActor () -> Bool)?` consulted in `triggerSync()`
  and `flush()` (every trigger road funnels there: settle, became-active, the post-configure
  trigger), nil = never held (every existing composition unchanged); the Mac wires it to the
  marker's read. The BANNER (`RestoreHoldBar`, beside `ProtectionNoticeBar` in the one
  bottom inset): the round-3 ruling's sentence rendered PROVISIONAL from `LibraryOpenCopy`
  (as-of day · Sync is waiting · deleted-will-leave/edits-will-return · duplicate-first) +
  **Resume Sync** = clear the marker + `services.resumeSync()` (QD composes free: the kept
  outbox pushes at the first resumed round because nothing cleared it). The banner renders
  whenever the hold stands, account or none (PROVISIONAL P-U2-2). On a machine with no
  custody/account the hold is additionally covered by the existing not-yet-enrolled state
  (round 3's "cheap" half — enrollment already waits on a deliberate press).
- **Row 9 — THE GUARD.** Core: `Persistence/LibraryPlacementGuard.swift` — two pure rules,
  headless-pinned: `isInsideICloudDrive(URL)` (the Mobile Documents home) and
  `isLiveLibraryFolder(picked:storeURL:)` (the store's own folder, or the store file itself).
  Faces: the backup-destination picker (`DataSafetyModel.chooseFolder`) REFUSES the live
  library's own folder with copy §6's why-not sentence verbatim (copy §8's note names this
  refusal as 13x's); the adoption door's confirm renders the same sentence as an
  informational line when the picked SOURCE sits inside iCloud Drive (the door adopts BY
  COPY, so the guard teaches rather than refuses there — the kickoff's "rides the door").
- **Row 8 — THE RESUME RECONCILIATION, pre-merge-safe half.** Core:
  `Persistence/LocalMachineryRecreation.swift` — the four local-only tables
  (`SyncSchema.localOnlyTables`) recreated inside a re-opened plaintext export BEFORE ANY
  WRITE (§14.13 + ledger 22: the copied outbox triggers still name them, so the landed copy
  takes no write until they exist), DDL restated from the migration WITH a schema-equality
  pin against a fresh store's `sqlite_master` (drift fails the suite); red-on-old: a write
  against an un-recreated export REFUSES (the old behavior demonstrated), lands after. The
  door's PLAINTEXT ROAD composes it: land the copy (a key-file-less `LibraryAdoption` plan —
  the U1 brain gains the optional-key-file arm), recreate the tables, then the
  `startNewLibrary` recipe verbatim over the landed file (fresh key + `StoreIdentity
  .establish` + Auto dials + `saveAuto` — ledger 5's "plaintext → fresh key + identity"; the
  route's open ENCRYPTS it, the shipped 13p migration); fresh tables = cursor 0 + empty
  outbox, so the same-account re-open enrolls and pulls with ZERO pushes — §14.13's letter,
  falling out of the shipped machinery rather than built beside it. Resume's routing is the
  EXISTING reconcile + doors (enroll via custody-absent enrollment with a fresh identity;
  the follow where keys rotated; foreign/no owner ⇒ the Connect/adopt road —
  `AppServices.connectLibrary`, shipped); NOTHING of it is rebuilt. POST-MERGE half, recorded:
  any engine-side hold line if the Shared chokepoint proves insufficient, and row 10's drills
  (returner/purge-fence · stale-outbox conflict cards · per-posture legs) — not this batch's.

#### PINS / DRILLS / COUNTS (filled as pieces land; PENDING until the run completes)

- **Row 7 core — `LibraryRestoreHoldTests`, 4/4 green** (headless `swift test`): the
  set/read/clear round-trip; a fresh adoption overwrites the standing hold; an UNREADABLE
  marker reads as HELD, never absence (the conservative direction — Resume still clears it);
  holds independent per store location.
- **Row 9 core — `LibraryPlacementGuardTests`, 2/2 green** (headless): iCloud Drive detected
  by the `Mobile Documents` path COMPONENT (component, never substring — pinned both ways);
  the live library's folder, the store file itself and a containing ancestor refuse as
  destinations while siblings and external volumes pass.
- **Row 6 core — `BackupRestoreCandidatesTests`, 3/3 green** (headless): the strict name
  filter over real fixtures (the A1-rail and malformed-stamp foreign names never listed);
  newest-first; the classifier-resolved serving key file per candidate (own pair ·
  fingerprint file · legacy file); decision 11's credential facts per wrap; the BARE class
  listed with nil credentials (said, never hidden); the SECOND LOOK lighting on the live
  key's pair by envelope fingerprint (fp8-less legacy names included) and never without a
  live key in hand.
- **Row 8 core — `LocalMachineryRecreationTests`, 3/3 green** (headless, over the PRODUCTION
  export): the RED-ON-OLD is live inside the pin — a synced-table write against the
  un-recreated export REFUSES WHOLE (the copied outbox trigger names the dropped table;
  ledger 22's recorded consequence demonstrated), the SAME write lands after recreation WITH
  its outbox row; §14.13's state verified (empty outbox · no cursor · no seqs before the
  write); the restated DDL pinned STRUCTURALLY equal to a freshly migrated store's
  (`PRAGMA table_info` per table — drift fails the suite) and the DDL map pinned to cover
  `SyncSchema.localOnlyTables` exactly (a future registry table without a restated CREATE
  fails loudly).
- **Row 8 core — the `LibraryAdoption` plaintext arm** (`LibraryAdoptionTests` now 6/6): a
  nil-key-file plan lands the export byte-identical with NO key file beside it (the fresh
  mint is the door's next step), the old family still steps aside whole, the source
  untouched; the U1 pins all green unchanged around the optional (`landedKeyFile: URL?`).
- **THE CORE SUITE, WHOLE (after every U2 core piece): 2247 tests in 255 suites PASSED**
  (`swift test`, 108 s, headless — plus the StringsWorkbook target's 40 in 6; U1's baseline
  was 2234/251, the +13/+4 are this batch's suites). The MAC APP TARGET COMPILES clean with
  every face wired (`xcodebuild -scheme Variorum build`, `** BUILD SUCCEEDED **` — a compile
  is not a stage act; no test host, no store).
- **The Mac pins — `VariorumTests/LibraryPortabilityDoorTests`, RAN UNDER THE SLOT
  (2026-10-07 04:20, GO "13x: go (40)"; claimed 40 min, used ~8, released on run 3's result
  line, no renew): 5/5 GREEN, `** TEST EXECUTE SUCCEEDED **`** — the HOLD GATE (held → zero
  transport calls on trigger AND flush; resumed → one round runs), the hold model's
  marker→Resume round-trip (Resume once, idempotent), the PICKER REFUSAL (the ONE sentence,
  nothing remembered; a sibling folder accepted), the flow's bare refusal speaking QC's
  remedy, and the WHOLE FLOW over a real pair (wrong word refuses and stays; the right word
  confirms; adopt lands byte-identical + canonical key file + the HOLD standing + custody
  carrying the opener + reopen into ready). Run 1's FIRST pass caught a test-harness gap
  (the dependency test-context guard at the reopen's AppSession) — fixed in the test alone
  (`withDependencies`, the Phase8 pattern, commit 13a88180), re-run green.
  **RED-ON-OLD, both reverts over the COMMITTED green (runs 2 and 3, rebuild each):**
  REVERT A (the two `roundsHeld` guards removed from `SyncSession.triggerSync`/`flush`) went
  red on EXACTLY the gate pin — `✘ heldRoundsNeverRunAndTheResumedFlushRunsOne … Expectation
  failed: await transport.dataCalls == 0` (a held session ran a round) — the other four
  green. REVERT B (the placement guard removed from `acceptPickedFolder`) went red on
  EXACTLY the picker pin, all three arms — `Expectation failed: model.note ==
  LibraryOpenCopy.pickedLiveLibraryFolderRefusal` · `model.note?.contains("corrupt a live
  database") == true` · `BackupDestination.isSet(in: defaults()) == false` (the live folder
  was REMEMBERED as a destination) — the other four green. Each restore by `git checkout --`
  on the one file, verified by an empty `git diff`; the behavioural revert verifies both
  guards in both directions. The refactor behind the picker pin: `chooseFolder` split at the
  panel seam (`acceptPickedFolder` — a real `NSOpenPanel` cannot run under a test host).

#### PROVISIONALS (recorded per row for the orchestrator; strings listed for 13s at the bottom)

- **P-U2-1** — "welcome" slot read as the absent-store face + the File menu (no distinct
  welcome state exists in the build).
- **P-U2-2** — the hold banner renders whenever the hold stands, signed in or not; Resume is
  always one press (on an account-less machine it clears the hold and does nothing else).
- **P-U2-3** — the Restore surface lists the IN-CONTAINER folder's pairs only for now; the
  second folder's rows wait on the walk's verdict (its copies open through File ▸ Open
  Library… meanwhile — the same flow, the user picks the file).
- **P-U2-4** — a GATED custody item beside a differing opener composes as `adoptOpeningKey`
  (the item is unreadable without a prompt BY DESIGN; the write is the same promptless
  delete-then-add, idempotent when the keys agree) — the rule applied, not changed.
- **P-U2-5** — a REFUSED custody save at the door's completion does not abort the adoption:
  the recovery roads cover the next launch (the key file's wraps; a plaintext road's refused
  silent item self-heals — `openStore` mints over a plaintext store), recorded rather than
  guessed into a rollback.

#### NEW STRINGS FOR 13s (every rendered word this batch mints; facts binding, words provisional — all in `App/Variorum/Shared/LibraryOpenCopy.swift` unless noted)

| string (constant) | where it renders |
|---|---|
| `openLibraryDoor` "Open Library…" | the File menu (QB door 1) |
| `restoreSectionTitle` / `restoreSectionBody` / `openCandidateDoor` | Data Safety's Restore section (QB door 2) |
| `sheetTitle` "Open a Library" | the flow sheet + the open panel |
| `bareStoreRefusal` (QC's remedy sentence verbatim at its tail) | the bare/keyless refusal |
| `newerSchemaRefusal` · `notAVariorumStoreRefusal` · `unreadableRefusal` · `wrongKeyRefusal` | the classifier-verdict refusals |
| `severalStoresLead` | the folder-holding-several chooser |
| `unlockLead` · `unlockWordsDoor` | the typed-roads step |
| `confirmLead` · `confirmStepAside` · `confirmFreshSlot` · `confirmSyncWaits` · `confirmPlaintext` · `confirmDoor` | the confirm step |
| `holdBanner(asOfDay:)` (round 3's ruled sentence) · `resumeSyncDoor` | the restore-hold banner |
| `credentialLine(_:secondLook:)` · `bareCandidateLine` | the Restore rows (decision 11 rendered) |
| `pickedLiveLibraryFolderRefusal` (lead + `ProtectionCopy.liveLibraryNotInICloudDrive` verbatim) | the backup-folder picker refusal (row 9) |
| `sourceInICloudDriveLine` (lead + the same ONE sentence) | the confirm's iCloud-Drive line (row 9) |
| `classifyingLine` · `adoptingLine` · `adoptionFailedLead` | the flow's progress/failure |
| (existing) `ProtectionCopy.libraryMissingOpenDoor` | NOW RENDERED on the absent-store AND waiting faces (shipped unrendered since pre-13x 1a) |
- The pin slot SLOTTED by 13o: after VM-10 (60–120 min, interruptible; 13o's own U2 walk may
  interleave) — the go is the literal token "13x: go (40)", est 2–3 h out; slot-1 discipline.
  AND: 13o's PR may merge TONIGHT — the merge ping would un-gate the post-merge half early;
  the conditional night plan: merge main INTO the branch (merge commits only — pushed history
  is never rewritten; "rebase" in the rule read as catch-up), then spawn the post-merge batch
  (row 10's drills — fake-server legs free, Mac pins filed with the scheduler); the
  orchestrator's WALK stays a considered act (the dev store's Castle gate may need her — the
  pre-13x 5b precedent), never forced overnight.
- Resequence (13o, within my slot-me-anywhere): 13o's U3 suite batch takes the next gap; my 40
  slides to ~05:00–06:00 after VM-10's remainder; the go token unchanged.
- 04:20 the go token honored: the door-pin slot ran ~8 of 40 min — run 1 green 5/5 (after a
  test-harness-only withDependencies fix, committed before any revert), revert A red exactly
  on the hold gate, revert B red exactly on the picker's three arms, both restored diff-empty;
  stage released on the result line, 13o confirmed. **U2's pre-merge half is FULLY evidenced —
  no pending Mac run remains.**

### BATCH U2b BRIEF — ROW 10's DRILLS (headless; a FRESH implementer; spawned under the
overnight mandate)

Read, in order: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md`; **this file
WHOLE** (the rulings, U1 + U2 RECORDS are your inputs); `notes/plans/pre-13x-postures-design.md`
§6 · §7 · §12 · §14 (corners 13 · 33 · 37 · 44); `notes/SyncSpec.md` §5–§7 (read-only);
`notes/sync-postmortem-fragments.md`. Code: the U1/U2-minted files; the convergence-suite
homes under `Tests/VariorumCoreTests` (the two-client fake-server harness).

**Do — ledger row 10, the drill set, ALL HEADLESS (fake server + throwaway stores; ZERO stage,
zero GUI):** (1) the same-Mac restore drill end to end — adopt a backup pair of a live
throwaway library, the hold ON, duplicate a since-trashed note inside the restored copy,
Resume → the duplicate SURVIVES the catch-up, the re-trashed original leaves (tombstone
catch-up said), the kept outbox's stale-dirty row lands as exactly ONE conflict card (the QD
pin); (2) the per-leg opens on an adopted copy — passphrase · twelve words · the older-key
day-passphrase pair (decision 11) · the same-fingerprint second look (the Standard/A leg
composes through the shipped in-memory custody seams — no real Keychain); (3) the plaintext-
export re-open end to end (export → classify → adopt → same-owner enroll from cursor 0 with an
EMPTY outbox, zero pushes; a foreign owner takes the adopt road); (4) the returner/purge-fence
drill — a backup older than a purge horizon reconciles through the 13j ledger at its first
round, nothing re-pushes a purged row; (5) the newer-schema refusal rendered honestly at the
model. **Record a DRILL TABLE** (leg × scenario × counts × verdict) in a `### U2b RECORD`.
**Fence unchanged:** zero `Sources/VariorumCore/Sync/` or custody-code or `Migrations.swift`
edits — new TESTS in test targets are fine and expected; a drill failure is traced at the
mechanism and fixed ONLY in 13x-owned Shared/Persistence code with a red-on-old pin; a fix
that demands an engine line is recorded `DEFERRED — post-merge` with the trace, never built
now. No stage claims; foreground waits; no subagents; commit per piece, push every commit;
LIVE STATUS from the first commit. Close with a "U2b DRILLS CLOSED" banner listing any
deferred pieces.

### U2b RECORD (the drills implementer's record; LIVE STATUS first — flipped in the same commit as each piece; PENDING = unverified)

**U2b DRILLS CLOSED — 2026-10-07.** Ledger row 10's five drill legs ALL GREEN, headless
end to end (fake server + throwaway stores under `swift test`; ZERO stage claims, zero
GUI, no subagents, foreground waits only). The DRILL TABLE below is the evidence: leg 1
the same-Mac restore (hold → duplicate-survives → Resume → tombstone catch-up → the QD
one-conflict-card pin, dumps byte-identical, one device identity); leg 2 the per-leg
opens (day's passphrase · twelve words · the in-memory A arm · the older-key day pair
byte-untouched across a re-key · the second look, with the collision rule's three
verdicts composed); leg 3 the plaintext-export re-open (same-owner cursor-0 catch-up
with ZERO pushes — §14.13's letter — and the foreign-owner adopt road into its own
partition); leg 4 the returner/purge fence (corner 37 verified by construction; the
purged family drops through the 13j ledger at the pre-drain reconcile, the kept outbox's
queued family edit SWEPT WITH IT — nothing ever reaches the server's fence); leg 5 the
newer-schema refusal at the model's two consults with the exact identifier facts. **THE
WHOLE CORE SUITE: 2254 tests in 258 suites PASSED** (115 s; +7 tests/+3 suites over the
U2 baseline 2247/255 — exactly this batch's three drill files) plus the StringsWorkbook
target's 40/6; skips are the standing env-gated three only. **THE FENCE HELD
ABSOLUTELY:** `git diff 96e8ccc8..HEAD` is three new test files + this record — zero
lines under `Sources/` at all, so zero `Sync/`, zero custody/keychain, `Migrations.swift`
untouched. ONE red across the whole batch, traced at the mechanism and fixed in the TEST
alone (leg 4's missing B-side janitor leg — the table row carries the trace); no
production fix was needed anywhere, so no red-on-old pin was owed (the hallucination
guard's fix clause never engaged). **DEFERRED PIECES: NONE** — no drill demanded an
engine line (the Shared `roundsHeld` chokepoint stood up to every leg; nothing
re-sequences post-merge from this batch). Deliberately NOT run here, already evidenced
elsewhere: the Shared faces' rendering (the hold gate/banner/picker/flow) is the U2 Mac
slot's 5/5 + two reverts — this batch asserts the core facts those faces render, and no
stage act ran. Commits: 997fe89e · 1232525b · c6f7fdea · 8eea177a · the close, every one
pushed at its landing.

#### INTERPRETATIONS RECORDED (for the orchestrator; none gates the core)

- **Leg 5's "at the model":** `LibraryOpenModel` is app-target code (a Mac-suite run —
  a stage act this brief forbids), so the drill runs the model's TWO CONSULTS 1:1
  (`land` = `LibraryClassifier.classify`; `settle` = `schemaVerdict(at:key:)`, verified
  call-for-call against the shipped source) and pins the exact facts its refusal
  `detail` joins; the rendering seam itself stands on the U2 slot evidence. If the
  orchestrator wants a model-face pin for the newer-schema arm specifically, it is a
  stage-slot item, not a headless one.
- **Leg 1's pool close:** the harness closes the pool and drains a leftover WAL through
  one keyed connection before adopting (the app reaches the same closed state through
  `AppBootstrap`'s lock road); recorded in the drill's own comment, test-world only.

#### LIVE STATUS

| leg | drill | status |
|---|---|---|
| 1 | Same-Mac restore end to end (hold → duplicate → Resume; tombstone catch-up; the QD stale-outbox conflict-card pin) | DONE (this commit; `LibrarySameMacRestoreDrillTests` 1/1 GREEN first run — the table row below) |
| 2 | Per-leg opens on an adopted copy (passphrase · twelve words · older-key day pair · same-fingerprint second look · the A arm) | DONE (this commit; `LibraryKeyLegDrillTests` tests (a)–(e) GREEN — the table rows below) |
| 3 | Plaintext-export re-open end to end (same-owner cursor-0 zero-push enroll · foreign-owner adopt road) | DONE (this commit; `LibraryExportAndReturnerDrillTests` 2 tests GREEN — the table rows below) |
| 4 | Returner / purge fence (a backup older than the purge horizon; nothing re-pushes a purged row) | DONE (this commit; same file, 1 test GREEN after the one traced composition fix — the table row below) |
| 5 | The newer-schema refusal at the model's consult (both classifier stages over a real pair; the sentence's exact facts) | DONE (this commit; in `LibraryKeyLegDrillTests` — the table row below) |

No revert is in flight (none ever started — no production code changed, so no
behavioural revert was owed). No subagents; synchronous foreground waits only; NO stage
claims (every drill is headless — fake server + throwaway stores under `swift test`).

#### THE SETTLED DESIGN, PER LEG (written before the code; revised in place as each lands)

All five legs are NEW SUITES in `Tests/VariorumCoreTests` (the fence's "new TESTS in test
targets" letter): they compose the U1/U2-minted brains (`LibraryClassifier` ·
`LibraryAdoption` · `LibraryRestoreHold` · `CustodyCollisionRule` ·
`LocalMachineryRecreation` · `StoreKeyEnvelope`'s wrap roads) with the two-client
fake-server harness (`SyncClient`/`FakeSyncServer`), in PRODUCTION'S round order
(`productionRound`/`productionQuiescence` — the RUN B default; purge legs use the
PurgeConvergence idiom of explicit rounds + dump equality instead, per `ProductionRound`'s
own doc). Where a drill asserts what a DOOR does, it runs the door's own recorded call
sequence (the `LibraryOpenModel.confirmAdoption` work closure: plan → execute →
custody-collision verdict → hold-set; the plaintext road's land → recreate → establish →
dials → saveAuto → hold). The Shared-seam faces themselves (the `SyncSession.roundsHeld`
gate, the banner, the model's refusal sentences) are ALREADY evidenced by the U2 Mac slot
run (5/5 + both reverts) — the drills assert the core facts those faces render, and no
stage act runs in this batch.

- **Leg 1 — `LibrarySameMacRestoreDrillTests.swift`.** Two devices (A on an ON-DISK
  ENCRYPTED store with in-memory custody, B in-memory) converge over the fake server; A
  dirty-edits a take (outbox row QUEUED, unpushed — the dead Mac's last words); the backup
  PAIR is taken from A (`db.backup(to:)` under the backup name + the pair's `.keys.json`
  beside — row 42's shape, fastKDF wrap); the account then moves on WITHOUT A (B edits the
  same take and pushes; B trashes a note and pushes). The restore: A's pool closed, the
  pair classified (`.snapshotPair`), the second look composes `alreadyAligned` (same key,
  live custody), `LibraryAdoption` plan/execute into A's own store path, the HOLD set —
  then, held: the kept outbox STILL carries the stale row (QD), the since-trashed note is
  LIVE in the copy and is DUPLICATED (`duplicateAsVersion` — fresh UUIDs). Resume = clear
  the marker + production rounds to quiescence with B. Pins: the duplicate SURVIVES on
  both devices and the server; the re-trashed original leaves again (tombstone catch-up);
  the stale-dirty row lands as EXACTLY ONE conflict card (S5) carrying the dead Mac's
  words, on both devices; same device identity throughout (same-Mac custody — the server
  sees no new device); outboxes empty, dumps byte-identical.
- **Leg 2 — `LibraryKeyLegDrillTests.swift` (with leg 5).** One encrypted library whose
  envelope carries ALL FOUR wraps (passphrase/fastKDF · the real BIP-39 twelve words ·
  an in-memory Apple key A · a master copy is decision 11's "online" arm, drilled as the
  wrap API's existing pins — not re-pinned here); a hand-off pair minted from it. (a) the
  day's passphrase unwraps the pair to the SAME key and the snapshot opens and reads; a
  wrong word refuses `wrongPassphrase`; (b) the twelve words unwrap and open; wrong words
  refuse; (c) the A arm: `unwrapKey(apple:)` with the in-memory A — nothing typed — opens
  it (the Standard-silent leg through the shipped seams, no real Keychain); (d) the
  OLDER-KEY day pair: the live library re-keys L1→L2 (`StoreEncryptionMigration.rekey`, a
  Replace-All-Keys-shaped event) with a NEW key file under a NEW word; the OLD pair's
  bytes are untouched (backup folders never rewritten — pinned byte-for-byte), it still
  opens by ITS day's word, the new word refuses on it, L2 does not open it; the collision
  rule composes `adoptOpeningKey` (custody L2 vs opener L1) — and `mintFreshCustody` with
  no custody (the new-Mac class); (e) the SECOND LOOK: a post-re-key snapshot's envelope
  `belongs(to:)` the live key ⇒ served from live custody, `alreadyAligned`.
- **Leg 3 — `LibraryExportAndReturnerDrillTests.swift` (with leg 4).** Origin client O
  (on-disk, keyed) syncs real content; `StorePlaintextExport.export`; the export
  classifies `.plaintextExport`; the door's plaintext road runs VERBATIM on a fresh
  machine path (nil-key-file `LibraryAdoption` → `LocalMachineryRecreation` →
  `StoreIdentity.establish` + fresh key → hold). §14.13 pinned BEFORE the first round:
  empty outbox, no cursor row, no row seqs. A fresh-identity client over the landed store
  (custody in-memory, the open ENCRYPTS it — the shipped 13p migration) resumes:
  pull-from-0 lands the corpus, the push pushes ZERO rows, cursor at head, dump
  byte-identical with O. The FOREIGN-OWNER arm: the same landed shape under a second
  provisioned account takes the adopt road (`restampOwner` + `resyncReinitialize`) — the
  upload lands in the NEW account's partition at its own sequence from 1, and the first
  account's rows are untouched.
- **Leg 4 — same file.** A (on-disk encrypted, pair-backed) and B converge on a family F
  + a bystander note; A dirty-edits a family take (outbox QUEUED); the backup pair is
  taken (F LIVE in it, cursor non-zero); A then deletes F, the stamps backdate past the
  30-day window, rounds run, A's janitor SWEEPS — F purged (mirror + local + ledger). The
  restore: the pair adopted on a FRESH machine path, opened by its day's word
  (`mintFreshCustody`), a FRESH device identity + the backup's non-zero cursor = corner
  37's RETURNER by construction. Its first round runs the scheduled shape
  (`reconcileLedger` → pull → push → sweep): the purged family drops locally through the
  13j ledger, NOTHING of F re-lands on the mirror (the stale outbox row included — the
  QUEUED family edit never resurrects the purged row), the ledger entries stand, the
  bystander and B converge with the returner by dump equality.
- **Leg 5 — in `LibraryKeyLegDrillTests.swift`.** The model's consult drilled 1:1 over
  REAL copies a newer build "wrote" (a future identifier inserted into
  `grdb_migrations`): stage 1 KEYLESS — the plaintext copy refuses `.newerSchema` with
  the exact identifier list; an ENCRYPTED newer copy honestly classifies as its pair
  (unreadable inside, by construction) and the POST-UNLOCK consult
  (`schemaVerdict(at:key:)`) returns `.newer` with the same exact identifiers — the facts
  `LibraryOpenModel.land/settle` join into the refusal's `detail` (the model's switch
  arms are the U2-evidenced Shared seam; its two consults ARE these calls, verified
  call-for-call against the shipped source and recorded here). A `.behindThisBuild` copy
  (an old store) stays an OPEN road, never a refusal — pinned beside it.

#### DRILL TABLE (leg × scenario × counts × verdict — filled as each leg lands; PENDING until its run completes)

| leg | scenario | counts | verdict |
|---|---|---|---|
| 1 | Same-Mac restore: converge 2 devices → the Mac's last edit QUEUED unpushed → backup pair (stamp-named + its own `.keys.json`) → account moves on (take edited + pushed; note trashed + pushed) → pool closed → classify `.snapshotPair` → second look `alreadyAligned` → adopt into the SAME path → HOLD set (as-of == the pair's stamp) → held: kept outbox verified, trashed note LIVE, `duplicateAsVersion` → Resume (clear) → production rounds to quiescence | cursor-at-backup > 0, restored cursor == it; conflict cards == 1 on BOTH devices, text == the dead Mac's words; server text wins the row; original re-tombstoned on both; duplicate live on both + the mirror; outboxes 0/0; dumps byte-identical; ONE device identity (same-Mac custody) | **GREEN first run** (`swift test --filter LibrarySameMacRestoreDrillTests`, 1/1, 0.126 s) — no failure, no fix, no revert |
| 2(a–c) | The hand-off FOLDER (QC's exact shape, `Variorum Library — <date>/` holding snapshot + fingerprint-named key file) classifies `.folderHoldingPair`; each wrap opens it: the day's passphrase · the twelve words (real BIP-39 mint) · the in-memory Apple key (nothing typed — the Standard-silent arm's cryptography, no real Keychain) | each unwrap == the SAME key and the copy opens and reads its marker; wrong word → `wrongPassphrase`, wrong words → `wrongRecoveryPhrase`, wrong A → `wrongAppleKey`; the source pair byte-identical after all of it | **GREEN** (`theHandOffFolderOpensByEachOfItsThreeWraps`, 0.148 s) |
| 2(d–e) | The OLDER-KEY day pair: snapshot pair under L1/P1 → the live library re-keys L1→L2 (`StoreEncryptionMigration.rekey`, Replace-All-Keys-shaped) with a new key file under P2, old live key file gone | the pair's two files byte-identical across the key event (never rewritten); the pair classifies as ITSELF and opens by ITS day's word → L1 → reads; P2 refuses on it (`wrongPassphrase`); L2 opens nothing of the old day (read throws); the live library reads under L2; collision verdicts compose `adoptOpeningKey` / `alreadyAligned` / `mintFreshCustody`; a post-re-key snapshot's pair `belongs(to:)` the live key (the second look) and opens under it | **GREEN** (`anOlderKeySnapshotPairOpensByItsOwnDayAndTheCollisionRuleComposes`, 0.206 s) |
| 5 | Newer-build copies, both consults (the model's `land`/`settle` calls 1:1): a plaintext copy with two future `grdb_migrations` identifiers; an encrypted copy with one, behind a real pair; an OLDER copy (last migration row dropped) | keyless: `.newerSchema` with the EXACT identifiers, sorted (the `detail` join pinned); ciphertext keyless: honestly the PAIR (schema unknowable); post-unlock: `.newer([the exact id])`; the older copy: `.behindThisBuild([the one unapplied])` — an open road, never a refusal | **GREEN** (`aCopyFromANewerBuildRefusesAtBothConsultsWithItsExactIdentifiers`, 0.201 s) |
| 3(same owner) | The door's plaintext road call-for-call on a NEW Mac: synced origin → `StorePlaintextExport` → classify `.plaintextExport` → nil-key-file adopt (no pair travels) → recreate → `establish` + fresh key → HOLD → Resume → fresh-identity client (the open ENCRYPTS the landed copy) → first production round | recreation == ALL FOUR tables; §14.13's pre-state verified before the round (outbox 0 · no cursor row · no row seqs); push accepted/rejected/deferred/purged == 0/0/0/0 (ZERO pushes); cursor 0 → head; the known note live; dump byte-identical with the origin; fresh identity ≠ origin's, its cursor recorded | **GREEN** (`theExportReopensUnderTheSameAccountFromCursorZeroWithZeroPushes`, 0.246 s) |
| 3(foreign owner) | The same landed shape under a SECOND provisioned account: the rows arrive stamped by the OTHER owner (asserted) → the adopt road (`restampOwner` + `resyncReinitialize`) → upload | cursor rewound to 0; accepted > 0, rejected/deferred 0; Y's head == its own accepted count (its own sequence from 1); the same row id lives under BOTH partitions independently; X's head UNCHANGED; outbox 0 | **GREEN** (`aForeignOwnersExportTakesTheAdoptRoadIntoItsOwnPartition`, 0.250 s) |
| 4 | Returner/purge fence: family + bystander converged LIVE → the queued family edit → backup pair → family deleted, stamps backdated past 30 days, rounds, A's sweep PURGES (mirror+local+ledger) → the pair adopted on a FRESH Mac (day's word; `mintFreshCustody`; HOLD) → fresh identity + the backup's non-zero cursor (corner 37 verified) → Resume → the scheduled first round (`reconcileLedger` → pull→push → sweep) | reconcile dropped > 0 rows; the family physically gone locally; the QUEUED family edit swept WITH the family (outbox entry gone — B2's letter) and `push.purged == 0` (nothing even reached the fence); the mirror holds nothing of the family; the ledger count UNCHANGED by the returner; the bystander lives; dumps r == b, outboxes 0/0; the new identity's cursor recorded | **GREEN** (`aBackupOlderThanThePurgeHorizonReconcilesAndNothingRePushesAPurgedRow`, 0.257 s). ONE red on the drill's first run, TRACED: the final dump equality failed because B had never run ITS OWN janitor leg — it still held the family's tombstoned rows while the returner had physically dropped them (the PurgeConvergence precedent's own step, "B's own sweep reconciles the rest"). A COMPOSITION gap in the drill, not a product mechanism — fixed in the test alone by adding B's sweep, with the pre-sweep state asserted so the trace stays visible; ZERO production code touched |

- **U2b DRILLS CLOSED (096e9b59)** — row 10's five legs all green headless (core 2254/258;
  the batch diff is three test files + the record, ZERO Sources/ lines; her store untouched;
  the one first-run red was drill composition, traced, fixed in the test alone). NO deferred
  pieces — the Shared chokepoint held through every leg. Two recorded interpretations: (a) the
  newer-schema MODEL-FACE pin is a stage-slot item — folded into the walk slot's list; (b) the
  leg-1 WAL-drain note is test-world only.
- **LADDER ROUND 1 OPENED overnight** (the build is complete pre-merge; zero deferred pieces,
  so the diff under review is the phase's whole diff): a fresh `fable-reviewer`, REVIEW_PROMPT
  verbatim, zero framing, report to `notes/plans/13x-ladder-round1.md` committed unedited.
  Remaining after it: fixes (if any) → the walk (stage; the dev-store Castle gate question —
  HELD FOR HER whether she unlocks it or we re-pose the dev store) → 13o's merge → catch-up
  merge + suite re-run → ladder round 2 → closeout.

### HELD FOR HER — ADDITION
- **The walk's dev-store gate:** the dev store stands in Castle behind Touch ID (the pre-13x
  5b precedent — no agent can pass it). For my hands-on walk of the two doors: either she
  unlocks the dev store at her morning sitting while I drive, or she authorizes re-posing the
  dev store (a throwaway posture change on the DEV scope only). Her call; nothing walked until.

## THE LADDER — ROUND 1 (2026-10-07; the report `notes/plans/13x-ladder-round1.md`, committed
unedited at 2999c13c; counts 1 BLOCKER · 1 MAJOR · 5 MINOR · 4 NIT; the clean bill's 14 items
noted, the reviewer re-ran all ten headless suites itself 49/49)

### DISPOSITIONS (the orchestrator, same-model arbitration, under the overnight mandate —
every fix lands with its own traced mechanism + red-on-old pin in F1; dispositions here are
the ruling of record)

| finding | disposition |
|---|---|
| **R1-BLOCKER** (same-Mac adoption of a Standard-era pair onto a Castle account leaves the live library Apple-openable — both reconcile detectors blind) | **ACCEPTED — F1's first fix.** The posture law is the spec; the adoption's landing must surface the owed follow/re-key exactly as the new-Mac road does. Custody code — LEGAL now (13o merged; the slot is 13x's again). F1 re-traces before fixing; the record's named red-on-old pin binds. |
| **R1-MAJOR** (the hand-off act has no door — deliverable 1 is brain-only) | **ACCEPTED — F1 builds the face:** the File-menu door + the Data Safety twin + reveal-in-Finder over `LibraryHandOff.produce`; words PROVISIONAL from the copy conventions, listed for 13s. An honest gap between U1's and U2's briefs — the orchestrator's miss, recorded as such. |
| M1 (the hold doesn't gate the ceremonies' direct `pullToHead`) | ACCEPTED, shape **P-R1-1 (PROVISIONAL)**: Replace All Keys / Use Castle REFUSE under a standing restore hold with one sentence — the pick-up-keys-first grammar's sibling. The plain follow stays untouched (traced honest: no content round). |
| M2 (`try?` swallows a failed hold write) | ACCEPTED: a failed hold write REFUSES the adoption before anything moves — nothing ever lands un-held. |
| M3 (`adoptionFailedLead` claims false recovery facts on pre-move arms) | ACCEPTED: per-arm copy; pre-move refusals say nothing moved. |
| M4 (the waiting-lobby Apple probe races a non-ready adoption) | ACCEPTED: the probe stops before `work` on every adoption road. |
| M5 (spurious Touch ID on provably-foreign pairs) | ACCEPTED: fingerprint comparison promptless first; the gated read only where custody's key could serve the pair. |
| N1 (Sync-now is a silent no-op under the hold) | ACCEPTED: it speaks the refusal (the one status seam, kind refusal). |
| N2 (`schemaVerdict`'s unannotated read-write fallback) | ACCEPTED: read-only open or the annotation stating why not. |
| N3 (the `LibraryRestoreHold` header's inaccurate claim) | ACCEPTED: comment corrected. |
| N4 (P-U1-1's implemented-but-unrecorded disposition) | ACCEPTED: recorded in F1's record pass. |

### FIX SESSION F1 BRIEF (a FRESH Fable implementer; spawned on the MERGED tree — main's
1dae44f8 is in; custody edits are IN-SLOT now)

Read: `CLAUDE.md` + auto-canon (note OverallModel §9's third trigger duty — post-merge canon);
`notes/SessionResiliencyProtocol.md`; **this file WHOLE**; **the round-1 report
`notes/plans/13x-ladder-round1.md` WHOLE** — the findings' own traces and named pins bind;
`notes/plans/pre-13x-postures-design.md` §3.3–§3.8 · §7 · §14 (corners 33 · 45);
`notes/plans/pre-13x-copy.md` §5 · §6. **Do, in this order:** (0) baseline — the whole core
suite headless on the merged tree, counts recorded (expect U2b's 2254/258 + 13o's additions);
(1) the BLOCKER per its disposition — re-trace the mechanism yourself first (the hallucination
guard), then the fix in the custody/landing seam, the record's red-on-old pin verified by
behavioural revert; (2) the MAJOR — the hand-off door's two faces + reveal-in-Finder +
PROVISIONAL strings (13s table extended); (3) M1–M5 then N1–N4 per the dispositions, each
with its pin where it guards behavior. **Stage:** the scheduler seat closed — the LOCK FILE is
the arbiter: claim honestly for your Mac pin runs ("13x F1 pins", short budget), release on
the result line, never hold through analysis. **Fences that remain:** zero
`Persistence/Migrations.swift` edits (claim `v1_23`+ HERE first if ever needed — not
expected); her real store never; no subagents; foreground waits; no trailers. Append
`### F1 RECORD` (LIVE STATUS first) from the first commit; commit per fix, push every commit;
close with an "F1 CLOSED" banner listing every finding → FIXED(hash)/recorded.

### THE NIGHT'S EVENTS — LADDER/MERGE ADDENDUM (for the bundle; chronological)
- Ladder R1 landed (2999c13c): 1 BLOCKER · 1 MAJOR · 5 MINOR · 4 NIT, all ELEVEN accepted at
  the dispositions table above. **For her morning eye, the two that matter:** the BLOCKER —
  the same-Mac Standard-era-pair-onto-Castle adoption would have left the live library
  Apple-openable in steady state (deliverable 3's own scenario; the reviewer's catch, exactly
  what the ladder exists for); and the MAJOR — the hand-off act had a brain but NO door (the
  orchestrator's gap between the U1/U2 briefs, owned as such).
- 13o's main MERGED into the branch clean (the catch-up; build green); custody work is
  IN-SLOT again. F1 spawned on the merged tree for all eleven findings.

### F1 RECORD (the fix session's record; LIVE STATUS first — flipped in the same commit as each fix; PENDING = unverified)

**F1 CLOSED — 2026-10-07.** All eleven round-1 findings landed per the dispositions table:
the BLOCKER and the MAJOR fixed with their faces and pins, M1–M5 fixed each with its pin,
N1–N3 fixed, N4 recorded (P-F1-1). Every behavior-guarding fix carries a red-on-old pin
verified by BEHAVIOURAL REVERT over committed state (M2's headless; the BLOCKER's, M1's,
M3's, M4's and M5's under the ONE stage claim "13x F1 pins" — claimed with the lock free,
~16 of 40 min used, released on the final result line; every revert red on EXACTLY its
named pin with every sibling green, every restore verified by an empty `git diff`). The
MAJOR's red is the reviewer's zero-caller grep (a missing feature; its new pins guard the
door now built). ONE production refinement landed mid-slot, found by the flow pin's run 0:
M2's step 3½ creates the store folder before the marker write (the empty-slot arm —
4dc05ed6, committed before any revert started). **FINAL COUNTS: Mac pins 76 tests in 4
suites PASSED (Phase13pControllerTests · Phase13pLobbyTests · LibraryPortabilityDoorTests ·
LibraryHandOffTests); the WHOLE core suite 2335 tests in 269 suites PASSED headless
(+1 over the merged-tree baseline 2334/269 — M2's adoption pin) + StringsWorkbook 40/6;
skips the standing env-gated ones only.** Zero `Persistence/Migrations.swift` edits, zero
migrations (marker stays 12); custody/ProtectionController edits were IN-SLOT per the
brief; her real store untouched; no subagents; foreground waits only; no trailers.

#### F1 CLOSED — every finding mapped

| finding | outcome |
|---|---|
| R1-BLOCKER | FIXED (e1ef77c0) — the `castleKeyFileAppleOpenable` reconcile arm; pin red-on-old by REVERT A under the slot |
| R1-MAJOR | FIXED (9ad6cc35) — both hand-off faces + reveal-in-Finder + strings; pins green under the slot (the old red = the zero-caller grep) |
| M1 | FIXED (a7e64a56) — the rotation ceremonies refuse under a standing hold; pin red-on-old by REVERT B |
| M2 | FIXED (a7e64a56 + 4dc05ed6) — the hold inside `execute`, step 3½; pin red-on-old by the HEADLESS revert (recorded above) |
| M3 | FIXED (bc50beeb) — per-arm failure words; pin red-on-old by REVERT C |
| M4 | FIXED (bc50beeb) — the lobby suspended before `work`, the in-flight probe closed; pin red-on-old by REVERT D |
| M5 | FIXED (bc50beeb) — promptless fingerprint comparison before the gated ask; pin red-on-old by REVERT E |
| N1 | FIXED (e8a8fd78) — the Sync-now door speaks the refusal (UI-honesty arm; the gate itself is the U2 pin's) |
| N2 | FIXED (e8a8fd78) — the fallback's recorded sentence at `schemaVerdict` |
| N3 | FIXED (e8a8fd78) — the `LibraryRestoreHold` header's false clause corrected |
| N4 | RECORDED (e8a8fd78) — P-F1-1 (the `plaintextLibrary` arm's returner story), QUESTIONS at the merge |

#### THE SLOT'S REVERT EVIDENCE (one claim, "13x F1 pins", ~16/40 min; every edit over committed state; restores by `git checkout --`, each verified by an empty `git diff`)

- **RUN 0 (green):** first pass caught M2's empty-slot gap (the hold write's parent folder —
  a REAL production refinement, fixed + committed 4dc05ed6 before any revert); re-run
  **76/4 PASSED**.
- **REVERT A** (the BLOCKER's reconcile arm removed): red on EXACTLY
  `anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy` —
  `Expectation failed: w.controller.followNotice` (no notice, no re-key, the wrap stands);
  the other 49 green.
- **REVERT B** (the M1 hold guard removed from `start()`): red on EXACTLY
  `aStandingRestoreHoldRefusesTheRotationCeremoniesAtTheDoor` — both arms
  (`model.phase == .failed(ProtectionCopy.resumeSyncFirst)` failed for `.enter` AND
  `.replaceKeys`); the other 49 green.
- **REVERT C** (`failureWording` collapsed to one-lead-for-every-arm): red on EXACTLY
  `theAdoptionFailureWordsAreTruePerArm` — 13 issues (every pre-move arm's lead claimed the
  dated/safety copy again; the mid-move lead gone); the other 7 green.
- **REVERT D** (the two suspension guards removed from `probeAppleRoad`): red on EXACTLY
  `aSuspendedLobbysProbeCompletesNothingEvenWhenAlreadyInFlight` —
  `Expectation failed: !completed && completions.value == 0` (the in-flight probe completed
  past the cancel); the other 13 green.
- **REVERT E** (the fingerprint condition dropped from the gated arm): red on EXACTLY
  `aProvablyForeignPairSkipsTheGatedAskAndASameKeyPairStillGetsIt` — `prompts.value == 0`
  and `== 1` both failed (the spurious ask fired on the foreign pair); the other 7 green.
- **FINAL (green):** the four suites **76/4 PASSED**; stage RELEASED on the result line.

#### LIVE STATUS

| finding | fix | status |
|---|---|---|
| (0) baseline | whole core suite headless on the merged tree | DONE (59fc3101) — **2334 tests in 269 suites PASSED** (133 s) + StringsWorkbook 40/6; skips the standing env-gated ones only (13o's gated measurement suites · the real-server pass · the fixture minters). U2b's 2254/258 + 13o's +80/+11, as the brief expected |
| R1-BLOCKER | the Castle/apple-copy reconcile arm + the landing's surfacing | DONE (e1ef77c0; mechanism re-traced and CONFIRMED — the settled-design entry; pin green + REVERT A red-on-old under the slot) |
| R1-MAJOR | the hand-off door's two faces + reveal-in-Finder + strings | DONE (9ad6cc35) — File ▸ Send Library to Another Mac… + Data Safety's "Moving to another Mac" twin over ONE flow (`LibraryHandOffModel` → `LibraryHandOff.produce` off-main → reveal-in-Finder), DECLARED (`.handOffLibrary`, menuBar+surface — the walk's letter), per-arm refusals; strings in the F1 table below; pins green under the slot |
| M1 | key ceremonies refuse under a standing hold (P-R1-1) | DONE (a7e64a56) — `restoreHoldStands` seam on the controller (nil = never held), the two ROTATION ceremonies (.enter/.replaceKeys) refuse `resumeSyncFirst` at `PostureSwitchModel.start` (leaveCastle traced engine-free, stays open; marker resume exempt); wired to the Mac's marker projection; pin green + REVERT B red-on-old under the slot |
| M2 | the hold write's failure refuses the adoption | DONE (a7e64a56 + 4dc05ed6) — the hold rides INSIDE `LibraryAdoption.execute` (step 3½, between safety copy and move: a failed write refuses `holdWriteFailed` with NOTHING moved; ordinary refusals leave no stray marker; nothing ever lands un-held; the store folder created first — the empty-slot arm); both door roads pass `holding:`, the `try?` swallows gone. Pin GREEN headless (`LibraryAdoptionTests` 7/7); red-on-old revert RAN AND RESTORED (red on exactly the new pin, 5 issues; restore by `git checkout --`, empty diff; 7/7 green after) |
| M3 | per-arm failure copy (pre-move arms claim no dated copy) | DONE (bc50beeb) — `failureWording(for:)` maps each `AdoptionError` arm to a TRUE lead (pre-move ⇒ `adoptionRefusedNothingMoved`; mid-move ⇒ its two real nets; landing + unknown keep the old lead, whose facts hold exactly there); the no-store-path guard reworded too; pin green + REVERT C red-on-old under the slot |
| M4 | the waiting-lobby probe stops before `work` | DONE (bc50beeb) — `StoreLobby.suspendForAdoption` (stop + flag; `probeAppleRoad` re-checks the flag PAST its await, closing the in-flight race the cancel alone cannot) · `resumeAfterAdoption` re-arms on a failed adoption · the model suspends BEFORE `work` and re-checks for a probe that won the race (ready road then); pin green + REVERT D red-on-old under the slot |
| M5 | fingerprint comparison before the gated prompt | DONE (bc50beeb) — `pairIsProvablyForeign` (both fingerprints on disk, promptless; differ ⇒ skip the gated ask; equal/unknown keep it); pin green + REVERT E red-on-old under the slot |
| N1 | Sync-now speaks the refusal under the hold | DONE (this commit) — the door consults `roundsHeld` and speaks `syncNowHeldRefusal` through the session's StatusCenter (kind refusal — §12's rule); UI-only arm, the gate itself is the U2 hold-gate pin's |
| N2 | `schemaVerdict`'s fallback annotated/read-only | DONE (this commit) — the fallback keeps its honest reason (a WAL-journaled copy refuses a read-only open) and now carries `openForInspection`'s recorded sentence verbatim-in-kind |
| N3 | the `LibraryRestoreHold` header corrected | DONE (this commit) — the false "move-aside relocates the whole store-folder family" clause replaced with the true guarantee (every adoption rewrites it — now INSIDE execute per M2; Resume alone clears) |
| N4 | P-U1-1's plaintextLibrary disposition recorded | DONE (this commit) — P-F1-1 below; QUESTIONS at the merge moment |

#### PROVISIONALS (F1's; they land in QUESTIONS at the merge moment per the shared-ledger rule)

- **P-F1-1 (R1-N4 — P-U1-1's IMPLEMENTED disposition, now recorded):** `LibraryOpenModel.land`
  routes `.plaintextLibrary` (a pre-13p FULL plaintext library) down the SAME plaintext road as
  an export — but unlike an export its four local-only tables SURVIVE (`recreateIfMissing`
  skips present tables), so a surviving cursor and possibly a non-empty outbox ride under a
  FRESH store id + fresh identity: a corner-37 RETURNER with QD-class outbox pushes, screened
  by the ledger reconcile at its first round. A DIFFERENT §14.13 story than the export's
  zero-push letter — now a recorded CHOICE, not a discovery (overturning it means wiping the
  four tables on the `plaintextLibrary` arm).
- **P-R1-1 (M1's ruled shape, applied):** Replace All Keys / Use Castle refuse under a standing
  restore hold with ONE sentence (`resumeSyncFirst`); Use Standard stays open (traced
  engine-free); the marker's crashed-rotation RESUME stays exempt (recovery — the
  followPending guard's own exemption).
- **P-F1-2 (M1's wiring breadth):** the hold consult is nil on compositions without the Mac's
  marker projection (the phone, tests) — never held there by construction; the phone gains no
  adoption door this phase, so nothing is reachable un-gated.
- **P-F1-3 (the BLOCKER's notice kind):** the adopted-pair exposure speaks under its OWN
  `FollowNotice` kind (`castleKeyFileAppleOpenable`) rather than re-wearing the decision-35
  sentence, whose "opens without asking" would be false under a gated custody; waiting body =
  its own sentence (the mismatch precedent: no keys replaced, sync not paused), sub-line
  shared with the mismatch (same fact). Words 13s's.
- **P-F1-4 (the hand-off door's shape):** the destination is a chosen folder (NSOpenPanel,
  Downloads default) rather than a fixed drop; the act is DECLARED (`.handOffLibrary`,
  menuBar + surface) while Open Library… stays the recorded undeclared standard-item class.

No revert is in flight (the slot's five ran and RESTORED — the evidence section above; M2's ran headless before it). No subagents; synchronous foreground waits only; the stage was claimed ONCE ("13x F1 pins", ~16/40 min) and is RELEASED.

**THE MAC SLOT'S PLAN (named BEFORE any revert started — the resiliency rule; every edit over COMMITTED state, so every restore was `git checkout --` on the one file, verified by an empty `git diff`):** claim "13x F1 pins" (≤40 min) → RUN 0 green (Phase13pControllerTests · Phase13pLobbyTests · LibraryPortabilityDoorTests · LibraryHandOffTests, test-without-building) → REVERT A (the BLOCKER's reconcile arm) → REVERT B (the M1 hold guard) → REVERT C (failureWording collapsed) → REVERT D (the probe's suspension guards) → REVERT E (the fingerprint condition) — each red on exactly its pin, each restored — → FINAL green → release on the result line. EXECUTED AS PLANNED; the outputs are the evidence section above.

#### NEW STRINGS FOR 13s (F1's additions to the U2 table; facts binding, words provisional — `LibraryOpenCopy` unless noted)

| string (constant) | where it renders |
|---|---|
| `handOffDoor` / the registry verb "Send Library to Another Mac…" (kept literally equal) | the File menu + Data Safety's door |
| `handOffSheetTitle` · `handOffPanelMessage` · `handOffPanelPrompt` | the destination panel + the sheet |
| `handOffProducingLine` · `handOffDoneLead(folder:)` (QC's teaching at the success moment) · `handOffRevealDoor` | the hand-off sheet |
| `handOffNoKeyFileRefusal` (corner 33 at the producing end) · `handOffFailedLead` | the refusal arms |
| `handOffSectionTitle` "Moving to another Mac" (the FAQ entry's name) · `handOffSectionBody` | Data Safety's section |
| `ProtectionCopy.followCastleKeyFileAppleOpenable` (the R1-BLOCKER notice's body/waiting line) | the follow notice + banner |

#### THE SETTLED DESIGN, PER FIX (written before the code; revised in place as each lands)

- **R1-BLOCKER — my own re-trace CONFIRMS the reviewer's mechanism at every step** (the
  hallucination guard's own walk, from the shipped source): (1) the adoption lands the
  Standard-era pair's key file (an `apple` wrap of L_old) beside the store whole
  (`LibraryAdoption` step 5, the canonical name); (2) `landCustody` reads
  `effectiveGate` — same store id ⇒ enrolled ⇒ `Posture.derive` `.indeterminate(shape:)`
  (StoreProtection.swift:92–94), the raw key behind the gate ⇒ shape `.castle` ⇒
  `.biometric` ⇒ `saveGated(L_old)`; (3) at ready, `reconcileFollow`'s rotation arm keys
  on `custody.corpusKeyID != vaultKeyID` (ProtectionController.swift:621) — the ids AGREE
  (this device followed the Castle entry when it happened; custody's sync material is
  untouched by the adoption); the decision-35 arm keys on `shape == .silent` (:641) — the
  shape is GATED; the follow-into-Standard arm needs `hasAppleHeldCopy` — false;
  `reconcileAppleKey` under determined Castle only clears flags (:1453–1458). No detector
  ever closes the exposure; `StoreBackup.writeSnapshotKeyFile` then copies the LIVE key
  file's bytes into every post-restore snapshot pair. **The fix:** a fourth material-in-hand
  arm in `reconcileFollow` — the account DETERMINED Castle (`!reading.hasAppleHeldCopy`),
  ids agreed, and the LIVE key file carrying an `apple` copy ⇒ owe the follow under a NEW
  `FollowNotice.Kind` `.castleKeyFileAppleOpenable` (the silent shape keeps its own kind,
  whose sentence says "opens without asking" — factually wrong for a gated custody; the
  FILE is the exposure here, not the gate). The follow's act needs NOTHING new: the
  no-rotation road in `runFollow` (PostureSwitch.swift:767–787 — ids equal, same master, no
  previous key) re-keys the library and `retireOldKeyFiles` removes the apple-carrying file
  from the live folder; `locate` prefers the fingerprint-named current file, so a legacy
  format-1 file with wraps kept for old snapshots can never re-trigger the arm. Guards match
  the shipped decision-35 arm (`!switchInProgress`; the verdict writes nothing). New copy
  `followCastleKeyFileAppleOpenable` (PROVISIONAL, 13s's table extended); `waitingBody`
  renders the same sentence (the mismatch-kind precedent: no keys were replaced, sync is
  not paused, so the waiting line would be untrue); `laterSubline` reuses the castle
  mismatch's (accurate: writing stays under the old, Apple-openable key until the follow).
  **The pin (the record's named one):** in `Phase13pControllerTests` beside the decision-35
  pins — a gated-custody enrolled world whose key file carries passphrase AND apple wraps,
  vault reading Castle with the custody's own corpus id ⇒ the follow is OWED with the new
  kind; the sibling pins (gated shape + no apple copy under Castle ⇒ nothing owed; gated
  shape + apple copy under STANDARD ⇒ the silent follow into Standard) stand untouched.
  Red-on-old by behavioural revert: the new arm's if-block removed (the old behavior — no
  detector), the pin goes red, the siblings stay green; restore by `git checkout --`
  verified by empty diff.

## THE LADDER — ROUND 2 (2026-10-07; the report `notes/plans/13x-ladder-round2.md`, committed
unedited at 4533d27f): ten of eleven FIXED-PROPERLY; M4 INSUFFICIENT at one edge → R2-1;
new findings 1 MINOR · 2 NIT, ZERO new BLOCKER/MAJOR ⇒ no round 3 (the ladder rule); the
reviewer's own headless verification matched F1's counts exactly (2335/269 + 40/6 + 44/8).

### ROUND-2 DISPOSITIONS (the orchestrator, under the overnight mandate)

| finding | disposition |
|---|---|
| **R2-1** (MINOR — a press landing while state == .opening runs the adoption over a store the pool is opening; edits can land in the moved-aside file) | **ACCEPTED — F2 fixes.** The honest shape is SUSPEND-AT-FLOW-BEGIN or await-then-re-route for `.opening`; F2 re-traces and picks, the reviewer's named red-on-old pin binds. The M4 disposition's letter ("the probe stops before work on every adoption road") is only now fully satisfied. |
| R2-2 (NIT — `handOffDoor` is dead copy; the registry verb renders instead) | ACCEPTED — F2: ONE source of truth — the registry's declared verb reads the copy constant (so the 13s table's re-voicing is real), or the dead constant dies; F2 picks the one-line honest shape and pins it. |
| R2-3 (NIT — one unattributed full-suite flake, name lost) | **RECORD-ONLY:** unattributed on the evidence; the next two full-suite runs (F2's close + the closeout baseline) watch for recurrence; if seen again with a name, it gets its own trace — never a blind fix. |

### FIX SESSION F2 BRIEF (a FRESH Fable; the ladder's tail — small and strictly scoped)

Read: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md`; **this file's DISPOSITIONS
tables (both rounds), the F1 RECORD, and `notes/plans/13x-ladder-round2.md` WHOLE** (R2-1's
trace + named pin bind); then only the code the report names (`LibraryOpenModel.swift:347–352`,
`AppBootstrap.swift:229–231`, the hand-off faces for R2-2). **Do:** (1) R2-1 per its
disposition — your own re-trace first, then the fix, the named pin red-on-old verified by
behavioural revert; (2) R2-2's one-line honest shape + its render pin; (3) the full core suite
headless at close (watching for R2-3's flake — if it recurs, RECORD name + output, fix
nothing). Fences as F1's (no Migrations, no new Sync/ lines expected — R2-1's seam is Shared;
her store never). Stage: likely NOT needed (headless pins reachable per the report's test
shape); if a Mac run is truly owed, the lock file arbitrates — honest short claim. Append
`### F2 RECORD`; commit per fix, push; close "F2 CLOSED" with the finding map + final counts.

### F2 RECORD (the tail fix session's record; LIVE STATUS first — flipped in the same commit as each piece; PENDING = unverified)

#### LIVE STATUS

| finding | fix | status |
|---|---|---|
| R2-1 | the `.opening` edge closed: await-then-re-route at the press | DONE (efccfb6c) — pin GREEN by name (2.18 s, the mid-flight grace visible); REVERT F red-on-old VERIFIED (below); restore diff-empty |
| R2-2 | ONE source of truth: the registry verb READS `LibraryOpenCopy.handOffDoor` + the equality pin | DONE (e5987ccf) — `theHandOffVerbReadsTheOneCopyConstant` green in the 5-suite run |
| R2-3 | record-only: the close's full-suite runs watch | DONE — TWO clean full headless runs at close (2335/269 + 40/6, twice); the flake did NOT recur; nothing fixed, per the disposition |

**No revert is in flight (the slot is CLOSED; evidence below).** The one behavioural
revert, named here BEFORE it started per the resiliency addendum: **REVERT F (R2-1)** —
remove the F2 block from `LibraryOpenModel.confirmAdoption`'s non-ready arm (the
`while bootstrap.opening != nil` await loop and the `.opening` refusal arm), restoring
the old `.ready`-only re-check; expected red on EXACTLY
`aPressWhileTheProbesWonOpenIsInFlightDefersToTheReadyRoad` (phase lands `.done`, the
slot's bytes become the source's, the hold stands — all while the open is parked),
every sibling green; restore by `git checkout --` over COMMITTED state, verified by an
empty `git diff`. R2-2 gets NO behavioural revert by design: no
behavior differs on the old tree (the two strings are equal today — the reviewer's own
"no behavior is wrong today, hence NIT"), so a red-on-old demand would be hollow there;
the equality pin is the ENFORCEMENT of the no-drift claim going forward, red the moment
the registry verb decouples from the constant.

#### R2-1 — the re-trace (this session's own, per the hallucination guard; CONFIRMED against source)

1. The waiting lobby's probe (`StoreLobby.probeAppleRoad`, StoreLaunchGate.swift) completing
   between the sheet's open and the Adopt press calls `complete(key)` →
   `AppBootstrap.beginOpening` → `state = .opening`, the pool open detached for its whole
   duration (routing + SQLCipher open + migration check).
2. The press: `confirmAdoption`'s non-ready arm — `suspendLobbyForAdoption()` matches only
   the two LOBBY states (AppBootstrap.swift), a no-op at `.opening`; the old re-check was
   `if case .ready` only → `.opening` fell through to the detached work.
3. The wal gate (LibraryAdoption.swift step 2) refuses only a `-wal` with size > 0 — a
   just-opened pool that has not written leaves no such file — so the move-aside relocates
   the live store's inode out from under the in-flight open.
4. `reopenAfterAdoption` → `beginOpening` no-ops on `guard opening == nil`; the in-flight
   open's `finish` then installs a session over the aside-moved inode — edits land in
   `Previous Libraries/<stamp>/` while the adopted copy sits held at the live path.

**The pick (the disposition offered two shapes):** await-then-re-route, NOT
suspend-at-flow-begin — because suspend-at-begin does not close the edge, it only moves
it (a probe completing before ANY suspension still leaves `.opening`, where suspension
is a no-op against no lobby), it would demand resume plumbing on every cancel/refusal
road of the sheet, and it would retire the deliberate, recorded choice to keep the probe
alive while she merely browses. The landed shape, at the one place the work can launch:
after the F1 suspension, `while bootstrap.opening != nil { await bootstrap.awaitOpen();
bootstrap.suspendLobbyForAdoption() }` (each settle into a lobby is a FRESH instance
whose probe is live — hence the re-suspend per lap; the loop cannot spin, since each lap
awaits a real task and a completed task nils `opening` inside its own `finish`); then
`.ready` takes the ready road, whose teardown closes the pool the probe's open opened;
a residual `.opening` with NO open task (another ceremony's transient — unreachable from
this sheet in practice) REFUSES `adoptionRefusedNothingMoved` rather than racing it; the
other settled states take the detached road exactly as before (no pool stands in any of
them). The M4 disposition's letter — "the probe stops before work on every adoption
road" — is now satisfied on the last entry.

#### R2-2 — the one-line honest shape

The registry's `.handOffLibrary` now declares `verb: LibraryOpenCopy.handOffDoor`
(CapabilityRegistry.swift) — the copy constant is the ONE source of truth, so the F1 13s
table's re-voicing of that constant is real (it reaches the File menu and Data Safety
alike, both of which render the registry's verb); both sites' "can never drift" comments
replaced with the true mechanism, and the equality pin
(`theHandOffVerbReadsTheOneCopyConstant`, CapabilityRegistryTests) is the enforcement the
old claim never had. The alternative (killing the constant and re-pointing the 13s table
at the registry) was not taken: it would move a her-facing string out of the copy layer.

#### THE SLOT'S EVIDENCE (one claim, "13x-F2" — "13x F2 pins: R2-1 run + REVERT F + R2-2 equality pin", ~7 of 40 min; claimed with the lock FREE, released on the final result line; every edit over committed state)

- **BUILD:** `build-for-testing` SUCCEEDED with both fixes and both pins (no stage —
  a build, not a run).
- **RUN 1 (green):** the five suites — LibraryPortabilityDoorTests ·
  CapabilityRegistryTests · Phase13pControllerTests · Phase13pLobbyTests ·
  LibraryHandOffTests — **106 tests in 5 suites PASSED** (3.2 s); the R2-1 pin shown
  passing BY NAME (`aPressWhileTheProbesWonOpenIsInFlightDefersToTheReadyRoad`,
  2.18 s — the two-second mid-flight grace visible in its runtime).
- **REVERT F** (the F2 block removed, the old `.ready`-only re-check restored): red on
  EXACTLY the named pin with **4 issues** — `Expectation failed: model.phase ==
  .adopting` (the press landed `.done` with the open still parked) · `Expectation
  failed: try Data(contentsOf: storeURL) == liveBytes` (the slot's bytes became the
  source's mid-open) · `Expectation failed: !LibraryRestoreHold.isHeld(besideStore:
  storeURL)` (the hold stood mid-open) · the trailing ready guard (on the old road the
  press never awaits the open, so ready had not landed when the press returned) — the
  work RAN over the in-flight open, exactly the finding's mechanism; **every sibling
  green (8/8)**.
- **RESTORE:** `git checkout -- App/Variorum/Shared/LibraryOpenModel.swift`;
  `git diff` EMPTY (0 lines).
- **FINAL (green):** the five suites **106/5 PASSED** again; stage RELEASED on the
  result line.
- **THE CLOSE'S HEADLESS RUNS (R2-3's watch):** the whole core suite + StringsWorkbook,
  TWICE — **2335 tests in 269 suites PASSED (146 s) + 40 tests in 6 suites PASSED**,
  both runs, matching the F1 record and the round-2 report exactly. The round-2
  unattributed flake did NOT recur; per the disposition, nothing was fixed and the
  next full run (the closeout baseline) keeps watching.

### F2 CLOSED — 2026-10-07

| finding | outcome |
|---|---|
| **R2-1** (MINOR — the `.opening` residual of M4) | **FIXED (efccfb6c)** — own re-trace CONFIRMED; await-then-re-route landed (the press awaits any in-flight open, re-suspending each settle, then routes ready through `adoptLibrary`'s teardown; a task-less `.opening` refuses nothing-moved); pin red-on-old by REVERT F, restore diff-empty. The M4 letter — "the probe stops before work on EVERY adoption road" — is satisfied on its last entry |
| **R2-2** (NIT — `handOffDoor` dead copy) | **FIXED (e5987ccf)** — the registry's `.handOffLibrary` declares `verb: LibraryOpenCopy.handOffDoor` (ONE source of truth; the 13s re-voicing is real); both no-drift comments now state the mechanism; the equality pin `theHandOffVerbReadsTheOneCopyConstant` is the enforcement (green-on-old by the strings' present equality — the NIT's fix is structural, and the pin's red is the future decoupling) |
| **R2-3** (NIT — the unattributed flake) | **RECORDED, NOTHING FIXED** — did not recur across TWO full headless runs at this close (2335/269 + 40/6 twice); the closeout baseline keeps the watch |

**FINAL COUNTS: Mac — 106 tests in 5 suites PASSED (twice, around the revert); core —
2335 tests in 269 suites PASSED + StringsWorkbook 40/6 (twice).** Fences held: zero
`Persistence/Migrations.swift` edits (marker stays 12); zero `Sources/VariorumCore/Sync/`
lines (R2-1's seam is Shared, as the brief expected); her real store untouched; no
subagents; foreground waits only; no trailers; commits per fix, each pushed.

## THE MORNING SITTING (2026-10-07 — her rulings, verbatim where hers)

- **The ratify bundle: RATIFIED WHOLE** — P-U1-1…5 · P-U2-1…5 · P-R1-1 · P-F1-1…4 · F2's
  await-then-re-route shape, all 16 as recorded. They land in QUESTIONS at the merge moment.
  Her one note, verbatim: *"the only note i'll make is that VX-80 has been made and I want you
  to pull it in now and make the fixes under /architect-phase discipline. I'm concerned about
  some of the mechanics of airdropping and how they'll work when I already potentially have a
  different key on the machine, if all the key mechanics have been thought through, etc."*
- **VX-80 PULLED INTO 13x (supersedes her incident-day "after 13x is merged in"):** the
  Castle-follow recovery-door fix builds NOW, on THIS branch, under this phase's held
  Sync/-custody slot — a fresh Fable implementer (custody seam = Fable end to end), the
  record file `notes/plans/fixes/vx-80-castle-follow-recovery-door.md` brought over from its
  branch as the brief's spine, pin-before-fix per the record's named red-on-old shape, its own
  cold-review round over the VX-80 diff before the merge. VX-80 closes with the 13x PR;
  commits say "Part of VX-80". The vx-80 branch retires at the merge (its one commit is the
  record, which rides here).
- **The walk gate: UNLOCK WHILE I DRIVE** — she Touch-IDs the dev store at the walk; no
  re-pose.
- **The acceptance legs: Pro → Air, guided, AFTER the walk.** Known wrinkle to solve at the
  leg: the Air's installed app is public 0.9.2 (5178), which has no 13x doors — the receiving
  side needs a 13x build (plan: a dev build carried to the Air, her hands; decided at the leg).
- **The two workflow hiccups: RULE NOW** — options presented at this sitting; rulings land
  below when made.
- Operating context: oct7coordinator's author hold covers this closeout's walk, legs, short
  Mac pin runs and the /Applications refresh; this session messages it at the merge.

### THE HICCUP RULINGS (2026-10-07, this sitting — process canon; the canonical-doc edits land at the merge per the shared-ledger rule)

- **Hiccup A RULED — commit at bout start:** the bout-start `vx sync` commits+pushes the changed
  board snapshot immediately (message "board snapshot"), a NARROW named exception to
  build-sessions-never-push-main: the generated snapshot only, nothing else ever. Pull-first
  stands; a push conflict regenerates and retries. Lands in CLAUDE.md's Environment bout-start
  line at the merge.
- **Hiccup B RULED — the atomic row-edit ritual:** a kickoff's in-flight-table edit is ONE tight
  pull → edit → commit → push sequence with retry-on-reject (re-pull, re-apply, push). No
  structural change. Lands in both phase skills' Workspace-setup section at the merge (edited
  together, as ever).

### VX-80 BRIEF (the pulled-in fix — a FRESH Fable implementer, ONE session; custody seam = Fable end to end)

Read, in order: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md` (checkpoint per
piece, foreground waits, no subagents); **`notes/plans/fixes/vx-80-castle-follow-recovery-door.md`
WHOLE — the record is your spine** (mechanism, fix shape, the named red-on-old pin, code
anchors, the saveAuto check); this file's MORNING SITTING section; **`notes/SyncSpec.md` IN
FULL** (custody work); `notes/plans/pre-13x-postures-design.md` §3.6–§3.8 (the lobby roads) +
§7 (the follow). Code anchors as the record lists them (PostureSwitch, AppBootstrap,
StoreKeyEnvelope, StoreEncryptionMigration).

**Do, in this order:** (1) THE PIN FIRST, red-on-old (the record's shape: store under key B,
custody holding key A, newest sidecar wrapping B ⇒ today's code lands the doorless `.failed`
with `recovery: nil`) — confirm red before any fix line; (2) the fix per the record: in
`failedOutcome` (or a sibling arm), key-in-hand + NOTADB-class error + a wraps-bearing sidecar
beside the store ⇒ offer the SAME typed-secrets lobby the empty-custody arm offers; on unlock
the open proceeds → ready → housekeeping reconcile finds the pending marker → the resume
completes the interrupted follow (custody finally moves, snapshot, old key file retired, marker
cleared); (3) verify the unlocked-key re-landing (R1-M3's `saveAuto`) does NOT fire under the
Castle demanded gate on this road — a state-transition test says so; (4) state-transition tests
for the new arm; the two-client convergence suites untouched; (5) the full core suite headless
at close (it is also R2-3's flake watch). **Fences:** zero `Persistence/Migrations.swift`
(marker stays 12); ZERO `Sync/` lines expected — one genuinely demanded is a STOP-and-record,
the orchestrator rules; her real store never; the stranded fixture lives ON THE AIR — do not
reach for it, simulate per the record (a live-fire against a fixture COPY is a held, optional
her-leg). **Stage:** Mac pin runs STOP at the seam — record PENDING-behind-the-stage, end the
piece; the orchestrator runs or GOes them under the author hold. Commit per piece, message
tail "Part of VX-80"; push every commit; no trailers. Append `### VX-80 RECORD` (LIVE STATUS
first) to this file from the first commit; close with a "VX-80 BUILT" banner mapping record →
evidence.

## THE CLOSEOUT WALK (2026-10-07 evening, the orchestrator's hands, her attending — the dev
store found STANDARD-posture at launch, not the digest's Castle; no unlock needed; noted)

**Legs verified before the finding:** both doors render in the File menu (registry → GUI);
File ▸ Send Library to Another Mac… produced the pair end to end (destination panel Downloads-
default with the AirDrop-teaching line; `Variorum Library — 2026-10-07/` = ciphertext store
15.6 MB + key file `variorum-keys-54909c07…json`; done sheet + reveal); the `notAVariorumStore`
refusal verified live (her accidental worktree-folder pick — an honest refusal, correctly
worded); the adoption flow's classify→confirm on the produced pair rendered the ruled copy
exactly (step-aside sentence, picked-file-only-read, sync-waits-for-Resume; NO unlock step on
an aligned same-key pair — correct).

### WALK FINDING W-1 (BLOCKER-class by the ladder's grammar; found live, post-ladder)

**The READY-road adoption always refuses on its own live store's `-wal`.** Pressing Open This
Library from the RUNNING app refused: "The library couldn't be opened. Nothing moved…" naming
`…/Variorum-dev/variorum.sqlite-wal`. TRACE (the orchestrator's own, against source):
`AppBootstrap.adoptLibrary` tears down via `StoreBinding.lock()` (StoreBinding.swift:89) whose
close is a plain `outgoing.close()` — NO truncate checkpoint — and a closed pool leaves a
non-empty `-wal` on disk (the re-key road knew: `StoreEncryptionMigration` runs
`PRAGMA wal_checkpoint(TRUNCATE)` explicitly at :126/:274 before its swap); then
`LibraryAdoption` step 2's gate (lines 15–16: "a non-empty -wal refuses — the door closes the
pool first") reads size>0 ⇒ `moveAsideFailed`. The refusal ARM behaved honestly (nothing
moved, store reopened, no hold) — but the door can never act in its PRIMARY context, a P-2
Fire-and-DO break. Why every pin missed it: the door pins stub the bootstrap and the U2b
drills drove stores whose wal was empty by their construction road; no leg drove the REAL
ready-road teardown over a hot pool. **DISPOSITION (orchestrator, the architect mandate):
ACCEPTED — fix now, orchestrator's own (the adjudication-fix allowance), NARROW: checkpoint-
truncate inside `StoreBinding.lock()` before the close (`try? writeWithoutTransaction` PRAGMA;
a failed checkpoint degrades to today's honest refusal, never to an unlocked store), ZERO
`AppBootstrap` edits (the VX-80 session owns that file right now). Pins: (1) headless red-on-
old — a pool-written store locked via the binding leaves `-wal` empty on new, >0 on old;
(2) the walk re-run as the behavioral proof. The VX-80-diff cold-review round covers this fix
too (one review over the phase's whole added diff).**

### VX-80 RECORD (the implementer's record; LIVE STATUS first — the fresh Fable VX-80 session, 2026-10-07)

**LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified):**
- **PIECE 1 — the NAMED red-on-old pin + this record:** DONE (this commit —
  `App/Variorum/VariorumTests/VX80CastleFollowRecoveryTests.swift`, the suite "VX-80 — the
  Castle-follow recovery door", one test: the record's exact simulate shape). Compile check
  DONE — `build-for-testing` into a scratch DerivedData, `** TEST BUILD SUCCEEDED **` against
  today's code (the W-1 StoreBinding fix in the tree; pathspec-limited commits kept the two
  sessions' work apart, and W-1 has since landed as bf44f53f).
  **The RED run is PENDING-BEHIND-THE-STAGE** — exact command, from `App/Variorum/`:
  `xcodebuild -scheme Variorum -destination 'platform=macOS' test -only-testing:VariorumTests/VX80CastleFollowRecoveryTests`
  Expected on TODAY'S code: 1 test, FAILING at the `#require(recovery…)` line ("recovery was
  nil" — the doorless dead end her Air hit). That failure IS the red-on-old confirmation; the
  brief's order holds (no fix line lands before it is confirmed).
  **RED CONFIRMED** — the orchestrator ran the pin under the author hold at 21:58: 1 test
  FAILING exactly at the `#require(recovery…)` line (VX80CastleFollowRecoveryTests.swift:159,
  "recovery was nil"), the SQLCipher wrong-key signature in the log (hmac check failed for
  pgno=1). Red-on-old on exactly the named pin; the fix was unblocked.
- **PIECE 2 — the fix:** DONE (this commit, built AFTER the confirmed red; `swift build`
  green; the GREEN pin run + the revert evidence ride piece 4's Mac-suite run, stage-pending).
  Built exactly as designed, traced this session against the shipped code:
  (a) CORE (`Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift`): `StoreOpenError`
  gains the typed fact **`keyRejected: Bool`** (default false) — true for exactly one refusal
  class: an ENCRYPTED store whose resolved key (custody-held) failed the open with SQLCipher's
  NOTADB class (`DatabaseError.resultCode == .SQLITE_NOTADB`, caught around the `onDisk` call
  in `openStore`, gated on `presence == .encryptedOrUnknown`). R1-M3's own precedent: the
  failure surface keys on a typed fact, never on matching the reason's prose. No key material
  rides the reason (the failing statement is a schema read, never the redacted PRAGMA key).
  (b) APP (`App/Variorum/Shared/AppBootstrap.swift` `failedOutcome`, :407): the one guard
  widens — `error.keyUnavailable || error.keyRejected` — so the SAME wraps-bearing-sidecar
  check and the SAME typed-secrets LobbyFacts (demand `.passphrase`, no biometry) serve both
  classes. ZERO view changes: both failure faces already render a non-nil `recovery` lobby
  (StoreFailureView / MobileStoreFailureView, R1-M3's machinery). The unreadable-sidecar
  disposition (P11: doorless, the true cause worded) carries over unchanged.
  (c) Downstream is the STANDING machinery, untouched: unlock → `beginOpening(unlockedKey:)`
  → ready → `readyHousekeepingBody` → reconcile (its Apple arm already suppressed by
  `readSwitchPending`) → the marker's resume doors (ProtectionPane's Finish …, the
  replace-keys door's redirect) complete the interrupted follow — custody finally moves
  (`moveCustodyForSwitch`), snapshot, `retireOldKeyFiles` on the resume road (2d.4), marker
  cleared. The resume at `.rekeyLibrary`/`.custody` needs no passphrase on the follow shape
  (custody holds M′; `newKeyFromKeyFile` unwraps the new sidecar's master copy).
- **PIECE 3 — the saveAuto gate check (R1-M3's re-landing under the Castle demanded gate):**
  DONE (this commit — `underTheDemandedGateTheRecoveryUnlockLandsNoSilentItem` in the VX-80
  Mac suite; its run rides piece 4's stage-pending command). Traced mechanism: the re-land at
  `AppBootstrap.finish` is guarded by `!currentEffectiveGate.isDemanded`. On the recovery road
  under a DEMANDED gate (a gated-custody stranded shape — a Castle device's Replace-All-Keys
  crash window: the gated item holds stale A, the route's lobby biometric road releases A, the
  open fails NOTADB typed, the recovery lobby's typed word yields B) the gate derives demanded
  at ready, so saveAuto MUST NOT fire — the test asserts `backing.auto` stays nil through
  ready + a bounded settle. On the Air's own SILENT shape the effective gate honestly reads
  `.auto` at that instant (indeterminate posture, custody shape silent), so R1-M3's designed
  heal REPLACES the stale silent A with the proven B — strictly better custody (without it,
  every relaunch before the resume re-strands), and the resume's `moveCustodyForSwitch` then
  lands the Castle shape. BOTH behaviors pinned (the heal:
  `underTheSilentShapeTheProvenKeyReplacesTheStaleItem`).
- **PIECE 4 — state-transition tests for the new arm:** DONE (this commit). Core headless
  (`Tests/VariorumCoreTests/StoreEncryptionTests.swift`, KeyedStoreTests):
  `openStoreTypesAWrongKeyOpenAsKeyRejected` (typed `keyRejected` + NOT `keyUnavailable` + no
  key material in the reason (P15) + the right key still opens the untouched file) and
  `theEmptyCustodyRefusalIsNotTheWrongKeyClass` (the class separation's other side) — both
  GREEN headless (KeyedStoreTests 8/8). Mac suite (`VX80CastleFollowRecoveryTests`, now FOUR
  tests): the named pin · the demanded-gate saveAuto check · the silent-shape heal · the
  unreadable-sidecar doorless parity (P11 carried onto the new class). Compile check DONE
  (`build-for-testing`, TEST BUILD SUCCEEDED). **The GREEN run is PENDING-BEHIND-THE-STAGE**
  — the same command as the red run (`-only-testing:VariorumTests/VX80CastleFollowRecoveryTests`),
  expected 4/4 PASSING. Revert evidence: the RED already ran on the actual pre-fix tree (the
  orchestrator's 21:58 run — red-on-old on exactly the named pin, cleaner than a revert); any
  future revert re-verification must use the NAMED pin test alone (the three newer tests
  reference `keyRejected`, which the old tree lacks). The two-client convergence suites carry
  ZERO VX-80 lines (boot routing only).
- **PIECE 5 — the full headless core suite at close (R2-3's flake watch):** DONE — full
  `swift test`: **2338 tests in 269 suites, 3 issues in 2 tests, BOTH pre-existing W-1
  fallout, ZERO VX-80 failures.** The two: `KeyedStoreConvergenceTests.theEngineConverges
  OverOnDiskKeyedStoresAndTheFilesStayCiphertext` (`!walBytes.isEmpty` ×2 at :105 — the pin
  reads the WAL's bytes to prove they stay ciphertext, and W-1's checkpoint-truncate in
  `StoreBinding.lock()` now leaves the WAL EMPTY) and `LibraryKeyLegDrillTests.theHandOff
  FolderOpensByEachOfItsThreeWraps` (travelled-vs-home byte equality at :135 — same mechanism
  class: the home store's on-disk bytes moved under the checkpoint). BISECT EVIDENCE
  (throwaway worktree, removed after): GREEN at 94ad887e (pre-W-1) · RED at a8f58bdb (W-1 in,
  the VX-80 fix NOT yet in) · RED at HEAD, failure lines identical — the introducing commit is
  bf44f53f (W-1), not any VX-80 commit. HANDED TO THE ORCHESTRATOR (W-1 is their
  adjudication-fix; whether the two pins' premises update or the fix narrows is their ruling).
  Every other suite green (the StringsWorkbook target 40/40 included).

**Fences held:** zero `Persistence/Migrations.swift` (marker stays 12); ZERO `Sync/` lines —
none demanded by the traced fix (boot routing + one typed error fact); her real store never;
the Air's fixture untouched (simulated per the record).

**Tree-sharing note (machinery honesty):** this worktree is ALSO carrying the orchestrator's
W-1 walk-finding fix (uncommitted `StoreBinding.swift` edit at this record's first commit —
the walk record's own disposition names the split: the orchestrator owns StoreBinding, this
session owns AppBootstrap). Every VX-80 commit is pathspec-limited so neither session sweeps
the other's work.

**VX-80 BUILT — record → evidence (one line each):**
- *The mechanism (the record §"The mechanism"):* re-traced live against this branch —
  `Posture.derive` reads the stranded shape indeterminate-Standard-by-custody-shape ⇒ route
  `.open` ⇒ wrong-key NOTADB ⇒ `failedOutcome`'s `keyUnavailable`-only guard ⇒ doorless. The
  record's account confirmed exactly.
- *The pin, red-on-old (the record's named shape):* `theStrandedStoreOffersTheRecoveryLobby
  AndTheTypedWordOpensIt` — the orchestrator's 21:58 stage run on the pre-fix tree: FAILING at
  the `#require(recovery…)` line, "recovery was nil", the SQLCipher wrong-key signature
  (hmac check failed, pgno=1) in the log. Commits 838d68b6 (pin) → f88e51a5 (fix after red).
- *The fix shape (the record §"The fix shape"):* `StoreOpenError.keyRejected` (typed, core,
  `openStore`'s NOTADB-with-key-in-hand classification) + `failedOutcome`'s one guard widened
  (`keyUnavailable || keyRejected`) — the SAME typed-secrets lobby, zero view changes, zero
  new crypto roads; on unlock the standing machinery completes the follow (reconcile → the
  marker's resume doors → custody moves, snapshot, old key file retired, marker cleared).
- *The saveAuto check (the record's own instruction):* the demanded-gate test pins no-silent-
  item; the silent-shape heal pinned as designed (piece 3's trace).
- *State-transition tests:* core 2 (headless GREEN) + Mac 4 (compiled; run stage-pending).
- *Convergence suites:* zero `Sync/` lines; the only convergence-suite reds are W-1's,
  bisect-traced to bf44f53f (piece 5).
- *Fences:* zero Migrations (marker 12) · zero Sync/ · real store and Air fixture untouched.
- **DONE: the Mac suite's GREEN run — 4 tests in 1 suite PASSED** (the orchestrator, under the
  author hold, 2026-10-07 ~22:30, `-only-testing:VariorumTests/VX80CastleFollowRecoveryTests`
  on the fixed tree; the RED on old ran at 21:58). The piece-5 W-1 fallout (the two
  hot-WAL-premise pins) adjudicated by the orchestrator at 36615337 — W-1 stands, the pins'
  premises updated; full core then 2338/269 + 40/6 GREEN. **VX-80 BUILT — FINAL.** Its cold
  review rides the phase's post-walk review round.

### WALK FINDING W-2 (MAJOR; found live after W-1's fix let the adoption act)

**The post-adoption reopen leaves the window content-sized and un-resizable, the hold banner
off-screen.** The adoption landed perfectly on disk (Previous Libraries/<stamp>/ with store +
sidecars + key file; `variorum-restore-hold.json`; the adopt-safety copy — P-U1-5 verified
live) and the HOLD BANNER RENDERS EXACTLY AS RULED (the full-window capture:
"This is your library as of October 7, 2026. Sync is waiting — Resume to catch up with your
account. Notes you deleted since will leave again; edits made since will come back. To keep
something from this backup, duplicate it first — duplicates stay." + Resume Sync) — but the
reopened window measures 1440×2734 pt on a 1117-pt display, `set size` via System Events is
refused (it re-reads 2734), and the banner + bottom bar sit ~1600 pt below the screen edge:
the hold's ONE face is invisible and the Resume door unreachable by eye. MECHANISM
(hypothesis, to confirm in code): the lobby faces run under content-size window resizability;
the adoption reopen re-enters through a lobby-shaped state and the full library root then
renders under the lingering content-size regime — unbounded ideal height, user resize ignored.
NOTE for VX-81's file: this is the same teardown-and-reopen root seam the Air's crash fired
in. DISPOSITION: ACCEPTED — fix in-phase (the orchestrator's, unless it touches the
implementer's open files); relaunch behavior checked first (a sane relaunch bounds the blast
radius to the adoption's first session); evidence: the walk's full-window captures + a pin on
the resizability state if it proves state-derived, else walk-verified chrome with the capture
as the record.

**W-2 FIXED — the mechanism CONFIRMED, and it is the b6dae25 class, not a lobby regime.** The
hypothesis above was wrong and is corrected here: the relaunch reproduced the tall window
(1440×2781) while the hold stood, which pointed at the banner itself. `RestoreHoldBar`'s
ruled ~230-char sentence carried an UNLIMITED `fixedSize(horizontal: false, vertical: true)`
in the main window's bottom safe-area inset (non-scrolling chrome) — P-8's own named class
("chrome fixedSize texts always carry a lineLimit"); the window's near-zero-width minimum-size
probe measured it one character per line and that became the window minimum. FIX: the
load-bearing `.lineLimit(4)` (LibraryOpenDoor.swift). PIN: `ChromeMinHeightTests.
restoreHoldBarNearZeroWidthProbeStaysBounded` — RED ON OLD at **2668 pt** (the live window
read 2734 incl. chrome — the same number), GREEN with the limit; its second half pins the
sentence still renders whole at a real width.

**Why P-8's enforcement missed it (recorded for the class):** `ChromeLineLimitTests` scans only
BARE `.fixedSize()`; the explicit-axis form is invisible to it. The app holds **253**
explicit-axis sites, **158** with no lineLimit in the scan's window. Most sit where the probe
never reaches (sheets with width floors, scroll-backed forms) — but that is unverdicted, and
verdicting 158 sites is a sweep of its own, NOT 13x closeout work → ticketed (below).

**THE SWEEP TABLE — 13x's own diff (17 explicit-axis sites added):**

| host | sites | verdict | mechanism |
|---|---|---|---|
| `RestoreHoldBar` (main window bottom inset) | 1 | **FIXED** | `.lineLimit(4)` + the named pin |
| `LibraryOpenSheet` / `LibraryHandOffSheet` (sheets) | 13 | SAFE | `.frame(minWidth: 460)` — the probe never measures narrower than the floor (the R1-6 measured mechanism) |
| `DataSafetyPane` (Settings) | 3 | SAFE | `Form` + `.formStyle(.grouped)` is scroll-backed; content height never becomes the window minimum |

**A PRE-EXISTING RED, NOT 13x's:** `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy`
is red on MAIN — two bare `.fixedSize()` sites in `Core/Views/SearchAnswerFaces.swift:182/213`
(13o's search faces). The VX-83 search follow-up run is editing that file now; routed to that
session rather than fixed here (a 13x edit would collide with its merge). 13x's closeout Mac
run will show this one red and it is accounted for here.

### THE WALK — CLOSED (Mac side; 2026-10-07 ~22:15, the orchestrator's hands, now Opus 5.5 — her
mid-session switch, the Fable safeguards having interrupted the trace; the VX-80 implementer
stays Fable)

Re-run on the W-1 + W-2 fixed build, every leg green and seen:
1. File ▸ **Send Library to Another Mac…** → destination panel → the pair produced (store +
   key file) → done sheet. ✔
2. File ▸ **Open Library…** → a non-library folder → `notAVariorumStore` refusal. ✔
3. Open Library… → the produced pair → classify → the ruled confirm (no unlock step on an
   aligned same-key pair). ✔
4. **Open This Library** from the RUNNING app (the W-1 road) → adopted: the old library + its
   key file + sidecars in `Previous Libraries/<stamp>/`, the adopt-safety copy in
   `Backups/safety-copies/variorum-adopt-safety-<stamp>/`, `variorum-restore-hold.json` beside
   the store. ✔
5. The **hold banner** on a bounded 1440×1084 window (the W-2 road) — the ruled sentence +
   Resume Sync. ✔ Persists across a relaunch while held (by design). ✔
6. **Resume Sync** on the sync-off dev store → the hold marker CLEARED, the banner gone,
   nothing else (P-U2-2's account-less arm). ✔
7. Settings ▸ **Data Safety** → Copies + **Restore from Backup** rows with decision 11's
   credential lines and Open… doors. ✔
Walk debris: one stray click collapsed the dev store's "u1 welcome" shelf header (a view
toggle; the orchestrator's coordinate slip). Findings: W-1 and W-2, both FIXED with red-on-old
pins above. The real-device AirDrop leg remains hers (the Air brief, `13x-air-leg-prompt.md`).

**The main-side P-8 red — OWNED (searchfollowup's reply, 2026-10-07):** VX-83 minted member
ticket **VX-94** and pushed the fix to `vx-83-search-followup` at `84617ea6` (`.lineLimit(1)`
on the chip face stack and on the kind word; the badge was already compliant). Green is proven
in VX-83's stage batch and reaches main with VX-83's PR, which merges AFTER 13x. So 13x's
closeout Mac run shows `everyBareFixedSizeStatesItsLinePolicy` red, KNOWN and owned —
never a 13x regression.

## THE LADDER — ROUND 3 (2026-10-07 evening; the cap's last round — EARNED by new code after
round 2: VX-80 (custody seam, pulled in at her word), W-1 (StoreBinding), W-2 (chrome) and the
two adjudicated pins). A FRESH `fable-reviewer` (CLAUDE.md: custody ⇒ Fable review), spawned
with `notes/REVIEW_PROMPT.md` VERBATIM, `{PHASE}` = 13x, zero framing; the report lands at
`notes/plans/13x-ladder-round3.md`, committed unedited by the orchestrator. If the Fable
safeguards stop the reviewer, the cast change goes to her before any substitute spawns.

### ROUND-3 DISPOSITIONS (the orchestrator — same-model Fable review of Fable-built code, so the
orchestrator arbitrates against the spec; the report `notes/plans/13x-ladder-round3.md`,
committed unedited at 6cae36de)

| finding | disposition |
|---|---|
| **R3-1** (MAJOR — a hot-copied source adopts INCOMPLETE: step 5 copies the main file alone, the source's `-wal` tail is dropped; the shm-less sibling refuses with a false wrong-key sentence) | **ACCEPTED — F3 fixes.** Both premises re-verified by the orchestrator in source: `LibraryAdoption.swift` step 5 copies `plan.sourceStore` only; `LibraryOpenModel.settle` maps `.unreadable` → `wrongKeyRefusal`. The constraints the fix must meet: (1) the SOURCE is never written — "the file you picked was only read" stays literally true; (2) the landed library contains every committed row the source's `-wal` holds — the confirm read them, the landing must carry them; (3) the classify/verdict step tells a GENUINE key mismatch (the wrong-key sentence, true there) apart from a store it cannot read for another reason (`unreadableRefusal` or a new honest sentence) — never one sentence for both; (4) a `-shm` is a rebuildable index and is never trusted across a copy. F3 picks the mechanism within these and records why. Red-on-old pins per the report's shape (headless core). |
| **R3-2** (MINOR — the hold gates read `RestoreHoldModel.isHeld`, a cache refreshed only by the main window's `.task`) | **ACCEPTED — F3 fixes:** the gate closures (`roundsHeld`, `restoreHoldStands`) read the MARKER (`LibraryRestoreHold.isHeld(besideStore:)` — one stat) instead of the projection; the projection keeps serving the banner. Pin: the gate consulted with no view alive and a standing marker answers HELD. Not a live breach today (the reviewer said so plainly) — fixed because it is one line and the hold is her ruled safety. |
| **R3-3** (NIT — VX-95 projectless) | **DONE by the orchestrator:** VX-95 homed in project **12 — Hardening & perf validation**, Backlog at Medium per her ruling (a standing-fix run can still take it as a member). |

**No round 4 exists (the cap).** F3's fixes are verified by the orchestrator: an own re-trace of
each fix against the dispositions, every pin red-on-old by behavioural revert, the full core
headless green, then the Mac door suites in 13x's stage block.

### FIX SESSION F3 BRIEF (a FRESH `opus-implementer` — the standing cast: none of R3-1/R3-2 sits
in `Sync/`, custody/keychain or the editor seam; LibraryAdoption is file mechanics, the gate is
app composition)

Read, in order: `CLAUDE.md` + auto-canon; `notes/SessionResiliencyProtocol.md`; **this file's
ROUND-3 DISPOSITIONS above** and **`notes/plans/13x-ladder-round3.md` WHOLE** (R3-1's and
R3-2's traces and named pins bind); the U1 RECORD's row-3 move-aside design and the P-U1-5
mechanics in this file; then only the code the report names (`LibraryAdoption.swift`,
`LibraryClassifier.swift` `schemaVerdict`/`openForInspection`, `LibraryOpenModel.settle`,
`VariorumApp.swift`'s gate closures, `RestoreHoldModel.swift`, `LibraryRestoreHold`).

**Do, in this order:** (0) baseline — the whole core suite headless, counts recorded (expect
2338/269 + 40/6); (1) **R3-1 — the pins FIRST, red on today's code:** (a) keyed store, a row
written, the trio copied HOT beside its key file (the report's shape), run the door's real call
sequence (classify → schemaVerdict → plan/execute), open the landed copy under the key, expect
the walled row; (b) the shm-less hot copy: the verdict and the sentence it settles to are TRUE
(not wrong-key); (c) a GENUINE key mismatch still settles to the wrong-key sentence (green on
both sides — the class-separation guard). Then the fix within the disposition's four
constraints; re-run red→green; record the mechanism chosen and why. (2) **R3-2** — the gate
closures read the marker; its pin (no view alive, marker standing ⇒ held); a behavioural revert
shows it red. (3) The full core headless at close; the Mac pins you add or touch are compiled
(`build-for-testing`) and listed PENDING-behind-the-stage with exact commands — you NEVER claim
or touch `Tools/stage`, never run `xcodebuild test` (other sessions hold the stage tonight).
**Fences:** zero `Persistence/Migrations.swift` (marker 12); zero `Sources/VariorumCore/Sync/`;
zero custody/keychain-item changes; her real store never; the Air fixture never. No subagents;
foreground waits; commit per piece with message tail "(VX-6)"; push every commit; **NO
Co-Authored-By or any other trailer** (this repo's rule overrides any harness reminder). Append
`### F3 RECORD` (LIVE STATUS first) to this file from the first commit; close with "F3 CLOSED" —
each finding → FIXED(hash), the revert evidence, the final counts, the PENDING Mac commands.
Work only in `~/dev/variorum-13x`.

### F3 RECORD (the fix session's record — a fresh `opus-implementer`, 2026-10-07 late; LIVE STATUS first — flipped in the same commit as each piece; PENDING = unverified)

#### LIVE STATUS

| piece | status |
|---|---|
| 0 — baseline (whole core, headless) | DONE — `swift test` 2338 tests / 269 suites PASSED + StringsWorkbook 40/6 PASSED (146 s); skips = the standing env-gated set only |
| 1 — R3-1 pins (a)(b), red on today's code | DONE (1604cd95) |
| — STOPPED → RULED | The stop (1604cd95) was answered at 5cc2973d (the RULINGS section below): Q1–Q4 all yes, the mechanism and pin set RULED as written. RESUMED in the same session. |
| 1 — R3-1 pins, the ruled set — the old-tree run | DONE (this commit) — 7 pins compiled against TODAY's code, **all 7 RED** (15 issues; quoted in "THE OLD-TREE RUN" below). (b″) and the `.keyRejected` halves name the split's new case, so they land WITH the fix and their red is the behavioural revert. The core suite on this branch head is red by exactly these 7 until the fix lands. |
| 1 — R3-1 fix (the four constraints) | DONE (this commit) — `LibraryClassifier.withStagedRead` (stage 1's plaintext read + stage 2's consult; `openForInspection` and the read-write fallback GONE), `LibraryAdoption` step 5 lands main + non-empty `-wal`, never `-shm`; `SchemaVerdict.keyRejected` (VX-80's letter) beside `.unreadable(reason:)`; `settle` maps each to its true sentence. The 8 hot-copy pins + the premise-updated `theSchemaVerdictUnderAWrongKeyIsKeyRejectedNeverAGuess` GREEN; the 8 neighbouring suites 48/8 GREEN headless; zero `variorum-picked-*` residue in the 0700 per-user temp after the run |
| 1 — R3-1 Mac sentence pins (b″)(c) | DONE (this commit; COMPILED — `build-for-testing` ** TEST BUILD SUCCEEDED **; RUN **PENDING-behind-the-stage**) — `aGenuineKeyMismatchStillSettlesToTheWrongKeySentence` (green on both sides by design — the class-separation guard) and `aTornCopyUnderItsRightKeySettlesToTheUnreadableSentence` (red on old: the single `.unreadable` arm wore the wrong-key sentence), both through `LibraryOpenModel`'s real flow |
| 1 — R3-1 behavioural reverts A/B/C/C′ | DONE (this commit) — all four run over the committed 64412dba, each red exactly where predicted, each restored by `git checkout --` with `git diff --quiet` EMPTY and both files' sha256 matching the pre-revert capture (quoted in "THE REVERT EVIDENCE" below). **No revert is in flight.** |
| 3 — the full core at close | DONE — `swift test` **2346 tests / 270 suites PASSED** (178 s) + StringsWorkbook **40/6 PASSED**; the 9 skips IDENTICAL to the baseline's (the standing env-gated set); zero `variorum-picked-*` residue after the whole run |
| — **F3 CLOSED** | see "F3 CLOSED" below |
| 2 — R3-2 the gate closures read the marker + pin + revert | DONE (this commit; COMPILED, RUN + revert **PENDING-behind-the-stage**) — `RestoreHoldModel.markerGate` (one stat of `LibraryRestoreHold.isHeld(besideStore:)`) + `wireGates(sync:protection:)`, the composition root's ONE wiring (`VariorumApp` calls it; the two `{ hold.isHeld }` closures gone); the projection keeps the banner. Pin `theHoldGatesReadTheMarkerWithNoViewAlive` (marker written after wiring, projection stale ⇒ both gates HELD, zero transport calls; the clear opens both and a round runs) |
| 3 — `build-for-testing` + the PENDING Mac commands | DONE (64412dba — ** TEST BUILD SUCCEEDED **, private derived data `App/Variorum/DerivedData/13x-f3`, an APFS clone of the walk's; the walk's own products untouched) |

No revert is in flight. No subagents; synchronous foreground waits only; the stage is NEVER
claimed or touched by this session (no `xcodebuild test`, no app launch). The measurement
probe was a scratch test file, deleted uncommitted; its output is quoted verbatim below.

#### R3-1 — WHAT TODAY'S CODE ACTUALLY DOES (measured headless, real SQLCipher stores, this stack)

The pins' shape (the report's): a keyed library, its schema checkpointed into the main file
(an ESTABLISHED library), one row written with the pool OPEN — so it lives in the `-wal`
alone — and the folder copied HOT beside its key file; then the door's real sequence
(`classify(folder)` → `schemaVerdict(at:key:)` → `LibraryAdoption.plan/execute(holding:)`)
and the landed library reopened through `AppDatabase.openStore` under the key.

| shape (today's code) | consult verdict | what happened to the PICKED folder | landed library |
|---|---|---|---|
| (a) the hot trio, right key | `.current` | the source's **`-shm` REWRITTEN** (32768 bytes, changed) | walled row **ABSENT** (`nil`) — **the report's MAJOR premise CONFIRMED** |
| (b) shm-less hot copy, right key, writable folder | **`.current`** — NOT `.unreadable` | a **`-shm` CREATED** beside the picked store | walled row **ABSENT** |
| (b′) shm-less hot copy, right key, NON-writable folder (0555 — a locked volume/DMG/read-only share) | `.unreadable("SQLite error 14: unable to open database file - while executing SELECT * FROM sqlite_master LIMIT 1")` → today's settle: **the FALSE wrong-key sentence** | unchanged | — |
| torn copy (page 1 intact, tail cut), right key | `.unreadable("SQLite error 11: database disk image is malformed …")` → **the FALSE wrong-key sentence** | unchanged | — |
| hot trio, **WRONG** key | `.unreadable("SQLite error 26: file is not a database …")` → the wrong-key sentence (TRUE) | **the picked MAIN FILE REWRITTEN** (bytes changed) and its **`-wal` and `-shm` DELETED** — the read-write fallback's close-time checkpoint folded the wal's raw frames in; the walled row survives under the right key | — |
| closed store, wrong key | `.unreadable(… error 26 …)` → wrong-key (TRUE) | unchanged | — |

The pins' red output on today's code (quoted): (a) `title → nil` vs `"the-walled-row"`;
`variorum.sqlite-shm was rewritten`. (b) `title → nil`; `after.keys.sorted() →
[key file, "variorum.sqlite", "variorum.sqlite-shm", "variorum.sqlite-wal"]` vs `before →
[key file, "variorum.sqlite", "variorum.sqlite-wal"]`. (b)'s own `verdict == .current`
assertion is GREEN on today's code — the contradiction below.

**The two places the report's trace does not hold on this stack:**
1. *"GRDB's init runs no reading statement"* — it does: `Database.setUp()` ends with
   `validateFormat()`, `SELECT * FROM sqlite_master LIMIT 1`
   (`.build/checkouts/GRDB.swift/GRDB/Core/Database.swift:526`, `:645–651`). So EVERY
   first-read failure lands inside `schemaVerdict`'s init-scoped `do/catch` and takes the
   READ-WRITE fallback — which is what rewrote the picked main file in the wrong-key-hot row.
2. *"a copy WITHOUT its -shm fails at the first read"* — not in a writable folder: SQLite's
   read-only connection opens the `-shm` `O_RDWR|O_CREAT`, creates it beside the picked
   store, recovers, and reads `.current`. It fails (CANTOPEN → today's false wrong-key
   sentence) only where the folder is not writable — (b′). The report's SYMPTOM is real; its
   SHAPE on this stack is (b′) and the torn copy, not the writable-folder shm-less copy.
   (Also: "read-only connections never checkpoint" holds, but they DO write the `-shm`.)

**All four constraints remain achievable** — so this stop is the brief's
contradiction clause, not a can't-be-met one.

#### R3-1 — THE PROPOSED MECHANISM (awaiting the ruling; nothing built)

- **THE STAGED READ.** Every SQLite read of a PICKED file — stage 2's `schemaVerdict`, and
  (Q4) stage 1's `openForInspection` — runs on a private copy in the per-user temp
  directory: the main file plus its non-empty `-wal`, NEVER its `-shm`, opened normally
  (read-write — the copy is ours) so SQLite's own crash recovery folds the wal's committed
  frames in, exactly as the landing's reopen will. The picked file is never opened in place:
  no `-shm` created or rewritten, and the read-write fallback (the source-writing road)
  disappears. `FileManager.copyItem` clones on APFS (same volume ⇒ O(1)); otherwise ∝ the
  library once, at a deliberate door, off-main (the adoption copies the library twice
  already). A crash mid-consult leaves the copy in the temp dir until the OS sweeps it
  (ciphertext for an encrypted source; plaintext only for a plaintext source) — recorded.
- **THE LANDING (step 5).** Copies the source's main file + its non-empty `-wal`, never its
  `-shm`; the reopen's recovery folds the frames in. The landed main file stays
  byte-identical to the source's, so the existing byte-identity pins hold. The consult
  reads exactly the pair that lands.
- **THE SPLIT (constraint 3).** `SchemaVerdict` gains `.keyRejected` — VX-80's class letter
  (`SQLITE_NOTADB` ∧ presence `.encryptedOrUnknown` ∧ a key in hand,
  `AppDatabase+Dependency.swift`'s `keyRejected`); `.unreadable(reason:)` becomes every
  other failure (CANTOPEN, CORRUPT, I/O, a failed staging copy). `settle` maps
  `.keyRejected` → `wrongKeyRefusal` and `.unreadable(reason)` → `unreadableRefusal` with
  the reason as detail (stage 1's own mapping). The existing
  `theSchemaVerdictUnderAWrongKeyIsUnreadableNeverAGuess` pin's premise updates to
  `.keyRejected` (its "never a guess" protection kept).
- **THE PROPOSED PIN SET:** (a) and (b) as committed (red on old as quoted); **(b′)** the
  shm-less hot copy in a non-writable folder reads `.current` and lands whole — red on old
  (`.unreadable` CANTOPEN ⇒ the false wrong-key sentence); **(b″)** a torn copy under its
  RIGHT key is `.unreadable`, never `.keyRejected` (core), and settles to
  `unreadableRefusal` (Mac pin — red on old at the sentence level); **(c)** a genuine key
  mismatch, closed AND hot, is `.keyRejected` (core) and settles to the wrong-key sentence
  (Mac pin through `LibraryOpenModel`, compiles on both trees — green on both sides,
  PENDING-behind-the-stage), and over the hot trio the picked folder stays byte-identical
  (core — red on old: main rewritten, `-wal`/`-shm` deleted).

#### QUESTIONS FOR THE ORCHESTRATOR'S RULING

- **Q1** — accept the re-trace: pin (b) stays as committed (red on old by the wal-tail drop +
  the materialized `-shm`; its verdict assertion green on both sides), and (b′) + the torn
  copy carry the report's false-wrong-key symptom on this stack?
- **Q2** — is the source-WRITING found here (the wrong-key hot consult rewriting the picked
  main file and deleting its sidecars; the `-shm` rewrite in (a) and creation in (b)) inside
  R3-1's constraint (1) for F3 to fix? (My reading: yes — constraint 1 is literal, and the
  staged read removes the fallback entirely.)
- **Q3** — the staged copy's home: the per-user temp directory (above) acceptable?
- **Q4** — extend the staged read to stage 1's plaintext `openForInspection` (the same
  read-only-writes-`-shm` + read-write-fallback construction; NOT measured this session)?

### F3 — THE ORCHESTRATOR'S RULINGS ON Q1–Q4 (2026-10-07 late; re-trace verified in source:
GRDB `Database.setUp` ends in `validateFormat()` — `SELECT * FROM sqlite_master LIMIT 1` at
`.build/checkouts/GRDB.swift/GRDB/Core/Database.swift:645–651` — so every first-read failure,
a wrong key included, lands in `schemaVerdict`'s read-write fallback, which F1's own N2
comment already admitted can touch the picked source)

- **Q1 — ACCEPTED.** The re-trace stands: (b) stays as committed; (b′) the non-writable-folder
  shm-less copy and (b″) the torn copy carry the report's false-wrong-key symptom.
- **Q2 — YES, IN SCOPE, and it is the most important half of R3-1.** Any write to the picked
  source — the wrong-key rewrite of its main file, the `-shm` rewrite/creation — breaks the
  confirm's promise "the file you picked was only read" (constraint 1). F3 fixes it; a pin
  asserts the picked folder BYTE-IDENTICAL (every file, sidecars included) after each consult
  road, red on old.
- **Q3 — ACCEPTED, with two conditions:** (i) the staged copy lives in its own per-consult
  subdirectory of the per-user temporary directory (owner-only on macOS) and is removed on
  every exit path (a `defer`), so only a crash can leave one; (ii) the record states the
  residue honestly — ciphertext for an encrypted source, plaintext only for a source that was
  already a plaintext file she holds. The copy's cost is ∝ the picked library (an APFS clone
  where possible) — acceptable for a one-time act the user started (P1 binds steady state,
  not a deliberate whole-file act).
- **Q4 — YES:** stage 1's plaintext `openForInspection` takes the same staged read — same
  construction, same constraint; measured in the session, pinned where it differs.
- **The mechanism as proposed is RULED:** the staged read (main + non-empty `-wal`, never
  `-shm`, opened read-write as OUR copy); the landing copies main + non-empty `-wal`, never
  `-shm`; `SchemaVerdict.keyRejected` on VX-80's exact class definition, `.unreadable(reason:)`
  for every other failure; `settle` maps each to its TRUE sentence; the existing wrong-key
  pin's premise updates to `.keyRejected`. Then R3-2 as settled. Continue.

### MERGE ORDER + VX-83's MIGRATION (her ruling and a sibling's fact, held here until F3 paused)
- **Her ruling (2026-10-07):** VX-83 MAY MERGE BEFORE 13x — first-ready merges first; 13x
  catches up by a MERGE COMMIT (never a rebase of pushed history), then re-runs core before
  round 4. Bug-fix PRs (vx-82andmore) may land first likewise.
- **VX-83 claims `v1_23_savepoint_search`** — searchfollowup's definitive answer: the v1_22 class
  exactly (local-only derived search index + INSERT-only capture triggers; no mirror; marker
  stays 12; zero deploy). 13x's install refresh does not wait on it; the orchestrator re-checks
  the marker after any catch-up merge anyway.

#### F3 RESUMED — THE OLD-TREE RUN (2026-10-07 late, after the rulings at 5cc2973d)

`swift test --filter LibraryHotCopyAdoptionTests` on the pre-fix tree (only the pins
changed): **7 tests, 7 RED, 15 issues** — each red the one its shape predicts:

| pin | old-tree red (quoted) |
|---|---|
| (a) `aHotCopiedLibraryLandsWithEveryRowItsWalHolds` | `title → nil`; `variorum.sqlite-shm was rewritten` |
| (b) `anShmLessHotCopyReadsTrueAndLandsWhole` | `title → nil`; after `[…, "variorum.sqlite-shm", …]` vs before without it |
| (b′) `anShmLessHotCopyInANonWritableFolderReadsTrueAndLandsWhole` | `verdict → .unreadable(reason: "SQLite error 14: unable to open database file - while executing SELECT * FROM sqlite_master LIMIT 1")` (the old `settle` ⇒ the FALSE wrong-key sentence) |
| (c) `aWrongKeyConsultLeavesThePickedFolderByteIdentical` | after `[key file, "variorum.sqlite"]` vs before `[…, "variorum.sqlite-shm", "variorum.sqlite-wal"]`; `variorum.sqlite was rewritten` (462848 bytes, changed) |
| Q4 `aHotCopiedPlaintextLibraryClassifiesWithoutATouchAndLandsWhole` | `title → nil`; the `-shm` rewritten |
| Q4 `anShmLessHotPlaintextCopyClassifiesWithoutATouchAndLandsWhole` | `title → nil`; a `-shm` created |
| Q4 `anShmLessHotPlaintextCopyInANonWritableFolderClassifiesTrue` | `verdict → .unreadable(…, reason: "SQLite error 14: unable to open database file …")` (stage 1 ⇒ `unreadableRefusal`, false: the copy is whole); `title → nil` |

**Q4 measured — where the plaintext road DIFFERS:** the same three behaviours as the keyed
road (the `-shm` rewritten/created; the wal tail dropped at the landing), and the
non-writable arm reads `.unreadable` CANTOPEN in BOTH the read-only open and its read-write
fallback — so on stage 1 it settles to `unreadableRefusal` ("This file couldn't be read as a
library."), not the wrong-key sentence; false all the same (the copy is whole). Pinned.

#### THE REVERT EVIDENCE (core, headless — `swift test --filter "LibraryHotCopyAdoptionTests|LibraryClassifierTests"`, 28 tests in 2 suites; over the committed fixed tree 64412dba)

| revert (one file, never committed) | red — exactly these, every other pin green | restore |
|---|---|---|
| **A** — `LibraryAdoption.swift` step 5 drops the `-wal` copy (the old main-file-alone landing) | **6 tests / 6 issues**, every one `title → nil`: (a) `aHotCopiedLibraryLandsWithEveryRowItsWalHolds`, (b) `anShmLessHotCopyReadsTrueAndLandsWhole`, (b′) `anShmLessHotCopyInANonWritableFolderReadsTrueAndLandsWhole`, and the three plaintext pins | `git checkout --`; diff EMPTY; sha256 OK |
| **B** — `withStagedRead` reads the PICKED file in place (the old read-only open + read-write fallback) | **7 tests / 11 issues**: (a) `variorum.sqlite-shm was rewritten`; (b) a `-shm` appeared; (b′) `got .unreadable(reason: "SQLite error 14: unable to open database file …")`; (c) the folder lost `-wal` + `-shm`, `variorum.sqlite was rewritten`; plaintext trio `-shm` rewritten; plaintext shm-less a `-shm` appeared; plaintext non-writable `got .unreadable(… error 14 …)` + `title → nil`. (b″) stays green — a torn copy has no wal to fold. | `git checkout --`; diff EMPTY; sha256 OK |
| **C** — the split collapsed: every failure `.keyRejected` (the old one sentence for both) | **1 test / 2 issues**: (b″) `aTornCopyUnderItsRightKeyIsUnreadableNeverTheWrongKeyClass` — `verdict → .keyRejected`, "a torn copy reads unreadable, got .keyRejected" | `git checkout --`; diff EMPTY; sha256 OK |
| **C′** — the over-correction: the `.keyRejected` arm removed (a genuine wrong key falls to `.unreadable`) | **2 tests / 3 issues**: (c)'s hot AND closed `== .keyRejected` (`→ .unreadable(reason: "SQLite error 26: file is not a database …")`), and `theSchemaVerdictUnderAWrongKeyIsKeyRejectedNeverAGuess` — the class-separation guard bites in BOTH directions | `git checkout --`; diff EMPTY; sha256 OK |

Pre-revert sha256 (64412dba): `LibraryAdoption.swift` 77204a95…ad17 · `LibraryClassifier.swift`
0f8d55fa…4b7f — matched after every restore.

**The Mac pins' reds are PENDING-behind-the-stage**, by the recipes in the closing section:
the torn-copy sentence pin under REVERT C (expected: `.refused(wrongKeyRefusal)`), the
genuine-mismatch sentence pin under REVERT C′ (expected: `.refused(unreadableRefusal, …)` —
it is green on both sides of the ORIGINAL tree by design), and the R3-2 gate pin under its own
revert (`markerGate` reading the projection).

### F3 CLOSED — 2026-10-07 late

**NOT DONE BY THIS SESSION (first, as owed):** the Mac pins' RUNS and their three Mac
behavioural reverts are **PENDING-behind-the-stage** (the stage was never claimed or touched —
no `xcodebuild test`, no app launch); no walk. A PRE-EXISTING phone-target compile break
was found and is **NOT fixed** (a different unit — observation 1 below).

**The finding map:**

| finding | disposition | commits |
|---|---|---|
| **R3-1** (MAJOR) | **FIXED** — the four constraints, each pinned: (1) the picked folder byte-identical after every consult road (keyed trio · shm-less · non-writable · wrong key · torn · the three plaintext roads); (2) the walled row lands (keyed + plaintext roads); (3) `.keyRejected` vs `.unreadable(reason:)`, each settling to its true sentence; (4) no `-shm` is copied or opened, ever | pins 1604cd95 + 86bc76b0 · fix **df6b9464** · Mac sentence pins 64412dba · reverts 13a87320 |
| **R3-2** (MINOR) | **FIXED** — both gates read the marker through `RestoreHoldModel.wireGates` (Mac pin compiled; run + revert PENDING) | **64412dba** |
| **R3-3** (NIT) | the orchestrator's — DONE before F3 (VX-95 homed) | — |

**THE MECHANISM, AND WHY (as ruled at 5cc2973d):** a **STAGED READ** — every SQLite read
of a picked file, stage 1's plaintext read and stage 2's consult alike, runs on our own copy
(the main file + its non-empty `-wal`, never its `-shm`), opened read-write in a per-consult
0700 subdirectory of the per-user temp directory and removed by `defer`. Why this and not
the report's two options: copying the `-wal`/`-shm` at the landing alone (option 1) leaves
the CONSULT writing the picked folder (measured: the `-shm` rewritten/created; under a
wrong key the read-write fallback rewrote the picked MAIN file and deleted its sidecars),
and the `-shm` is not trustworthy across a copy; refusing a hot source (option 2) would turn
away a whole, readable library — the ordinary Finder copy of a crashed or force-quit one. The
staged read never opens the picked file in place, so constraint (1) holds by construction
on every road (a non-writable folder included, where the in-place read failed outright); it
reads exactly the pair the landing carries (main + non-empty `-wal`, never `-shm` — step 5),
so (2) "the confirm read them, the landing carries them" is literal; SQLite's own crash
recovery rebuilds the index from the wal on both copies, so (4) holds. The split rides VX-80's
exact class letter (NOTADB ∧ encrypted presence ∧ a key in hand), so the wrong-key sentence
renders exactly where it is true (3). **Crash residue, stated honestly (Q3):** a crash
mid-consult leaves one `variorum-picked-<uuid>/` in the owner-only per-user temp directory
until the OS sweeps it — ciphertext for an encrypted source; plaintext only when the picked
file was already a plaintext file she holds. **Cost:** one copy of the picked library per
consult — an APFS clone on the same volume; a real copy elsewhere, at a deliberate,
user-started door.

**The revert evidence:** "THE REVERT EVIDENCE" above — A (6 reds), B (7), C (1), C′ (2), every
restore diff-empty with sha256 matched; the old-tree run (7/7 red) in "F3 RESUMED".

**Final counts (headless, at close):** core **2346 / 270 PASSED** (baseline 2338/269 + the 8
pins of the new suite `LibraryHotCopyAdoptionTests`) · StringsWorkbook **40 / 6 PASSED** ·
skips identical to the baseline. Mac `build-for-testing` ** TEST BUILD SUCCEEDED **
(64412dba). Phone target: compiles clean with ONLY the pre-existing N1 line neutralised
(observation 1; restored, diff-empty). Fences: F3's diff (`4748faaa..HEAD`) carries zero
`Sources/VariorumCore/Sync/`, zero `Migrations.swift`, zero custody/keychain files; zero
trailers on every F3 commit.

**THE PENDING MAC COMMANDS** (from `App/Variorum/`, under a HELD stage claim; the bundle is
pre-built at `DerivedData/13x-f3` from 64412dba — every later F3 commit is record-only):

1. **The green run** (the door suite — its 8 standing pins + F3's 3):
   `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/13x-f3 test-without-building -only-testing:VariorumTests/LibraryPortabilityDoorTests`
   — expect 11/11, including `aGenuineKeyMismatchStillSettlesToTheWrongKeySentence`,
   `aTornCopyUnderItsRightKeySettlesToTheUnreadableSentence`,
   `theHoldGatesReadTheMarkerWithNoViewAlive`.
2. **The three Mac reverts** — each: apply the edit, `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/13x-f3 build-for-testing` (no stage), then under the claim
   `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/13x-f3 test-without-building -only-testing:VariorumTests/LibraryPortabilityDoorTests`,
   then `git checkout -- <file>` and `git diff --quiet`:
   - **REVERT C** (`Sources/VariorumCore/Persistence/LibraryClassifier.swift`, `schemaVerdict`'s
     last `catch` returns `.keyRejected`) ⇒ `aTornCopyUnderItsRightKeySettlesToTheUnreadableSentence`
     RED (`got That key file doesn't open this library — it belongs to another copy.`).
   - **REVERT C′** (the same file, the `catch let error as DatabaseError where … NOTADB …` arm
     deleted) ⇒ `aGenuineKeyMismatchStillSettlesToTheWrongKeySentence` RED
     (`.refused(unreadableRefusal, "SQLite error 26 …")`). Green on the pre-F3 tree too — the
     guard is green on both sides of the ORIGINAL change by design.
   - **REVERT R3-2** (`App/Variorum/Shared/RestoreHoldModel.swift`, `markerGate` returns
     `{ [weak self] in self?.isHeld ?? false }` — the projection, the old `{ hold.isHeld }`) ⇒
     `theHoldGatesReadTheMarkerWithNoViewAlive` RED (both gates `→ false`; `dataCalls == 0`
     false).

**OBSERVATIONS (found, measured where said, NOT fixed — outside F3's surface; the
orchestrator owns their homing):**
1. **The phone target does not compile on this branch** — `App/Variorum/Shared/SyncStatusViews.swift:471`
   (`services.session.status.refuse(...)`, F1's N1 at e8a8fd78): "value of type 'AppSession'
   has no member 'status'" under `xcodebuild -scheme VariorumMobile -destination
   'generic/platform=iOS Simulator' build`. The ONLY error; with that one line neutralised
   (scratch, restored) the phone target builds clean — so F3's Shared changes are iOS-clean.
   Owed before the merge.
2. The landing's copies keep the SOURCE's file mode and flags (pre-existing for the main
   file; the `-wal` copy inherits the same): a Finder-locked or read-only source would land as
   a locked/read-only library. Unmeasured. (The staged read normalizes its own copies.)
3. A stray `-wal`/`-shm` at an EMPTY slot (no live store beside them) is not in the departing
   set (pre-existing): a landing would sit beside a foreign sidecar; with F3 a source `-wal`
   copy refuses there as `landingFailed`. Unmeasured edge.
4. R3-2's honest residue: with no main window, the marker-held gates refuse while no banner
   is on screen to offer Resume (the banner reads the projection; the next main window's
   `.task` shows it) — the ruled contract holds; the Sync-now refusal sentence names the
   banner, which renders in the main window.
5. The R3-2 pin drives `wireGates`; `VariorumApp`'s single call site is not pinnable without a
   view (a re-inlined `{ hold.isHeld }` there would not redden it) — recorded.

