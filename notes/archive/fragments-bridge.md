# The Fragments journal bridge — ARCHIVED 2026-09-04

**What this is:** the record a future session finds by grep when it meets the word "bridge" and wonders where
the code went. The Fragments journal bridge (Phase 9b, hardened through 9c · 14b · 14d) was RETIRED from `main`
on 2026-09-04 at the author's ruling (pre-13x design §1 ruling 16, 2026-09-03/04: *"I'll run the removal before
this phase — seems like it would be cleaner and there's no reason not to do it"*). The code is ARCHIVED, not
disabled — a disabled bridge would still compile, still claim a key provider, and still carry fourteen test files
through every future key change.

## Where the code is

- **Tag (the immutable marker):** `archive/fragments-bridge-2026-09-04` — the last `main` commit before removal
  (`32d3fdf`). Pushed to `origin`.
- **Branch (for humans browsing):** `archive/fragments-bridge`, at the same commit. Pushed. **Never rebased, never
  "kept up to date"** — it is a photograph. Revival is a re-implementation guided by it, never a merge of it.
- **The plan and record of the removal:** `notes/plans/pre-13x-bridge-retirement.md` (§2/§2b the inventory, §3 the
  steps, §6 the record with the commit hashes, §8 the cold review's findings).

## What was removed (the inventory, from the plan's §2/§2b)

- `Sources/VariorumCore/Bridge/` — `BridgeEncryption` · `BridgeEngine` · `BridgeScheduler` · `FragmentsContract` ·
  `FragmentsSession` · `FragmentsTransport` (2,226 lines): the engine (push `renderedText` per `entry_date`, land
  Fragments edits through ordinary ops with S5 guarding conflicts), the scheduler, the journal-class E2EE seam, and
  the Fragments-project RPC dialect over `journal_entries`.
- `Operations.applyBridgeLanding` — the landing overwrite (ONE transaction: insurance auto-commits, the overwrite,
  the landed body's own commit). The sixth quiet auto-commit occasion went with it (OverallModel §3 now names five).
- `AccountRekey` step 6 — `BridgeEngine.stageRepushFromTruth`; the re-key marker now clears after step 5.
- The bridge's LOCAL-ONLY tables `bridge_state` / `bridge_day` — DROPPED by migration `v1_16_drop_bridge_tables`
  (the creating migration `v1_4_bridge_state` stays: migrations are append-only). Never synced, so no SyncSpec §12
  lockstep event; the marker stays 7.
- App side: `Shared/BridgeSession` · `Shared/BridgeStatusViews` (the sidebar's bridge status row) · `AppServices`'
  bridge composition · `SyncSession`'s round-completed trigger · `DeviceBridgeKeyProvider` · the Fragments-project
  DELEGATED session (`custom:stargazing` browser flow INTO the Fragments project — `AuthSession`/`AuthViews`/
  `SignInFlow`) · `ProjectConfig`'s Fragments constants · Settings ▸ Account's "Journal bridge (Fragments)" section ·
  the Takes-mode "what Fragments sees" clause · Settings ▸ Savepoints' Fragments-landing insurance line.
- Tests: 16 core files (4,319 lines — `Bridge*Tests`, `Fragments*Tests`, `FakeFragmentsServerTests`, the three
  `Support/` harness files) and the Mac `Phase9bBridgeWiringTests`, plus the bridge legs of `AccountLifecycleTests`,
  `EncryptionFlowTests`, `Phase8ServicesTests`, `Phase9cAuthWiringTests`, `NoteVersionsPaneTests`.

## What deliberately STAYS

- **The `journal_bridge` class key in the suite vault format** (`KeyVaultFormat.KeyClass.journalBridge`,
  `DeviceKeyMaterial.journalBridgeKey`, the `key_vault` columns) — minted at enrollment and re-key, held in custody,
  compared in the custody-matches-vault check, and DORMANT. The vault format is a deployed wire shape shared with
  Fragments' own side; changing it is a §12-class event, not a retirement's.
- **`BridgeHash.body`** (SHA-256 hex of the UTF-8 bytes) — moved out of the deleted module into core `Domain/`
  unchanged, name kept: it is the sample library's manifest hash recipe (the BUNDLED manifest was computed with it),
  and `Sync/SampleLibraryDedupe` names it. The name is history; the recipe must never change.
- `resolveSyncConflict`'s `label` parameter (generic S5); `shelveInDailyJournalBook` (⌘J and the phone use it); the
  Variorum-project DIRECT sign-in (14a) whole; the ONE Stargazing account and the suite issuer (14a/14d).
- `notes/fragments-bridge-contract.md` — the carry channel to the Fragments agent, kept as history; its last entry is
  the 2026-09-04 CARRY ITEM telling that side the bridge is retired and nothing is owed.
- Every 9b/9c/14a–14d plan, handoff and archive paragraph: history, untouched.

## If it ever comes back

Her words at the kickoff (2026-09-04), verbatim: *"At some point, maybe in the collaboration phase, I'd bring back
the fragments bridge under some kind of collaborator shape but this code should just be an archive to reference."*
The revival shape (pre-13x design §1 ruling 16): **shared rows on Variorum's OWN sync in a collaboration era** — a
Fragments user as an outside collaborator on a journal book — never a second sync engine. The era is **13m** (the
variorum edition — file sharing, the collaboration pre-requisite) or whatever collaboration phase follows it; the
design is that sitting's, guided by the archive above.
