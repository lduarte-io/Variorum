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
| 1 | The classifier (verdict table pinned) | U1 | NOT STARTED |
| 2 | The hand-off producer (folder pair; round-trip pin) | U1 | NOT STARTED |
| 3 | Adopt-by-copy move-aside brain (mechanics PROVISIONAL → QUESTIONS) | U1 | NOT STARTED |
| 4 | Custody-collision memo + rule (read-only now; write-path → U2 post-merge if needed) | U1 | NOT STARTED |
| 5 | VX-64 — VaultBootstrap onto StoreUnlock (closes the ticket) | U1 | NOT STARTED |
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

#### LIVE STATUS

| row | piece | status |
|---|---|---|
| 1 | The classifier (verdict table pinned) | DONE (811c1e23 + the red-first evidence below) |
| 2 | The hand-off producer (folder pair; round-trip pin) | BUILT, compiles (`build-for-testing` green); pins PENDING — the Mac-suite run waits on the stage (held by the VM-5 merge orchestrator at claim time); runs before U1 closes |
| 3 | Adopt-by-copy move-aside brain | DONE (this commit; `LibraryAdoptionTests` 5/5 — mechanics PROVISIONAL P-U1-5) |
| 4 | Custody-collision memo + rule | DONE (memo at d2ca39f9 BEFORE the code; rule this commit, `CustodyCollisionRuleTests` 4/4; read-only composition confirmed — nothing re-sequences to U2's post-merge half) |
| 5 | VX-64 — VaultBootstrap onto the StoreUnlock road | NOT-STARTED — design settled below |

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
- The record-opening commit (`d2ca39f9`) carries a `Co-Authored-By` trailer against
  CLAUDE.md's no-trailer rule (the harness reminder won a reflex it should not have).
  Caught immediately after the push; a pushed commit is never rewritten without her word,
  so it stands recorded here and every subsequent commit is trailer-free.
