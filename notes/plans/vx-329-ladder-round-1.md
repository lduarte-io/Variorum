# VX-329 — ladder round 1 (cold review, Fable, 2026-10-22)

**Reviewer:** fresh `fable-reviewer`, REVIEW_PROMPT verbatim, zero implementation context.
**Scope:** the whole phase diff `e37eaa6b5..HEAD` on `vx-329-release-switch` (318 files, +6,433/−56,504; U1 the
switch + deletion, L0 lockstep 13→14, L1 the Sync/ carve, U3 one refresh authority, R1 the seven riders, the Mac and
phone fix legs, the pg_temp artifact, the switch-day script, the rewritten site delta brief).
**Canon read in full:** CLAUDE.md + auto-canon, `notes/CastleRules.md` whole (27 + the ledger), `notes/SyncSpec.md`
whole, `notes/SurfaceContracts.md` (The app · Doors), the plan whole, `notes/plans/vx307-deploy-checklist.md`,
`notes/plans/vx-329-switch-day.md`, the delta brief, QUESTIONS #237, KnownIssuesAndTechDebt.
**Review foci:** the plan carries NO "Review foci" section (checked — §6a/§6b/§6c are briefs, not foci), so none bind.
**Verification runs (mine, headless):** `swift build` green; targeted `swift test` green —
`StorePlaintextExportTests|JoinWordsMoment|AccountJoinTests|LibraryClassifierTests|VaultRewrapFormatTests|MCPGrantSchemaTests`
57/7 · `AuthRLSDDLTests` 78/1 · `VX307VaultArtifactTests|SyncSchemaTests` 18/2 ·
`CatalogTests|LibraryKeyLegDrill|LibraryHotCopyAdoption|StoreEncryptionMigration|LifecycleScenario|PurgeConvergence`
50/8 · `AccountLifecycle|MultiTenantSyncAttacker|SyncCustodyIdentity|AccountAct|NamesAndSeal|ProtectionLibraryFiles|
ProtectionRecordSchema|LocalMachineryRecreation` 44/10; `xcodebuild build-for-testing` (Mac, own DerivedData
`vx329-ladder1`) **TEST BUILD SUCCEEDED at the review tip**; full core debug suite re-run (result noted below).

---

## FINDINGS (severity-ranked)

**[MAJOR] · notes/plans/vx-329-switch-day.md §"§2's answer" + notes/plans/vx-329-release-switch.md §5 · the §2
proof's record does not exist while the script already claims it** · Evidence: the plan's §5 promises "the walk and
the rehearsals in §8; the closeout in §9" — neither §7, §8 nor §9 exists in the plan file (heading scan at the review
tip); the switch-day script's §2 answer says, in the completed voice, "REHEARSED (tonight): a fresh new-road library
joins a throwaway account whose vault is post-backfill-shaped and whose rows predate the join — the full pull
decrypts everything. *(Rehearsal record: §8 of the plan file.)*" — a pointer into a section that is not there; step
0's "the Pro's A1 + rehearsal byte copy are ALREADY STAGED (7/7 cmp-identical)" likewise has no repo record (I
verified the staged copy and the A1 folder EXIST on disk — `/Users/Shared/vx329-rehearsal/`,
`Backups/safety-copies/variorum-vx329-stage-20261022T115834Z` — but the 7/7 cmp claim and the §2 rehearsal have no
written evidence anywhere). §2 is, in the plan's own words, "the one question this phase must answer before any real
store crosses", and the script is written for her hands. Mechanism: a reviewer-of-record (or her morning self) reads
REHEARSED → trusts the join-and-full-pull proof ran green → crosses a real store on an unproven (or unrecorded)
claim; a session death tonight loses the only copy of whatever did run. · Fix: land the §8 rehearsal record
(accounts used, the planted vault shape, rows sealed pre-join, the join, the pull's decrypted counts — the §5R
form) BEFORE the pause hands the script to her; until it lands, the script's "REHEARSED" marks and the dangling §8
pointer must read PENDING. Record-class finding — the justification above, no pin.

**[MINOR] · Sources/VariorumCore/Persistence/StorePlaintextExport.swift:90–92 · the post-export sidecar sweep can
only ever delete a STRANGER's files now** · Evidence: with `PRAGMA plain.journal_mode = MEMORY` (the VX-461 fix) the
export itself creates no `-wal`/`-shm`/`-journal` sibling, so the sweep's three `removeItem` calls are a no-op for
the export's own litter and act only on pre-existing files of those names beside a user-picked path (inputs: she
exports to `foo.sqlite` in a folder where another app's `foo.sqlite-wal` lives → that file is silently deleted,
where the process has access — the sandbox's one-path grant blocks it in the shipped app, but any folder-granted or
unsandboxed context deletes for real). F-R1-1 already flags exactly this ("its one risk being a stranger's file of
those names beside a NEW pick. Delete or keep") — this finding is the ladder's answer: DELETE the sweep. · Pin
(red-on-old): in a plain writable temp folder, plant `<picked>-wal` with stranger bytes, run `export`, assert the
file survives — red on the current code (the sweep removes it), green with the sweep deleted.

**[MINOR] · notes/plans/vx307-deploy-checklist.md:56 · the Verify section's grant-sweep row contradicts the
checklist's own R-2 correction** · Evidence: the header (line 22–24) says "THIS WINDOW's post-deploy sweep expects
**62 OK · 4 INFO · 0 fail**, not the 13n-b counts (the sweep row below reads with that correction)" — but the row
below still reads "expect the 13n-b counts ±0" (13n-b was 63 OK). The pg_temp rehearsal (this phase) also read 62
OK. A her-hands checklist carrying two different expected counts is exactly where a tired window stumbles. · Fix:
one line — make the Verify row say 62 OK · 4 INFO · 0 fail (the marker-aware expectation). Doc-class, no pin.

**[MINOR] · notes/plans/vx-329-release-switch.md (L1 RECORD, "Canon note for the closeout") · the canon delta is
aimed at the wrong file** · Evidence: the note says "SyncSpec §3's `sync_state` key list still names
`rekey_in_progress`" — SyncSpec §3's list is `last_server_seq`, `device_id`; the stale `rekey_in_progress` line
lives in **AppSpec §7**'s local-only-machinery comment ("keys: 'last_server_seq', 'rekey_in_progress'"). A closeout
following the note edits SyncSpec and leaves the loaded canon stale. (SyncSpec §3's own `device_id` entry is ALSO
stale — pre-13x moved device identity to per-store custody — pre-existing, worth the same delta pass.) · Fix:
correct the note; at the merge, the two-file delta hits AppSpec §7 (and optionally SyncSpec §3's device_id line).

**[MINOR] · Server/supabase/maintenance/vx213-pg-temp-search-path.sql (+ Tests) · the pg_temp belt has no drift
pin** · Evidence: every precedent maintenance artifact is read by an `AuthRLSDDLTests` pin (`14c-gate-definer-owner`,
`14b-mirror-truncate`, `beta-signup-auto-entitle`, the grant sweep — all literally read in that suite); `rg vx213|
pg-temp` across `Tests/` and `Sources/` finds ZERO references to this artifact. Mechanism: a FUTURE lockstep
artifact that `create or replace`s a definer function with a bare `set search_path = public` (exactly what 17 does
to `key_vault_update` — the reason this artifact must run after it) silently regresses the belt, and nothing goes
red until someone re-runs the artifact's verify by hand in a live window. · Pin (red-on-old by construction):
an `AuthRLSDDLTests` arm that resolves each definer function's FINAL `set search_path` across the chain + this
artifact's alters and asserts a trailing `pg_temp` on every one — red with the artifact unregistered/ignored, green
once read. (Belt-and-braces class, as the artifact's own header says — hence MINOR, not MAJOR.)

**[MINOR] · Sources/VariorumCore/Crypto/VaultBootstrap.swift · an orphan kept on a dangling disposition** ·
Evidence: U1's record lists its deletion as "L1's call" ("NOT built … the deletion … of the 14b vault brains
(`Crypto/VaultBootstrap` etc. — L1's call)"); the L1 RECORD never rules on it; after the carve it has ZERO product
callers (`rg --word-regexp VaultBootstrap` outside tests: only its own file — the CLI shell left at U1, its other
consumer `CorpusRotation` left at L1; `SyncEngine.resyncReinitialize` itself stays live via PurgeJanitor:809, so
only the BOOTSTRAP wrapper is orphaned). Its own header now says "the tests are its only caller". · Fix: one
recorded decision — delete the file with its suite, or write the keep-with-reason in the L1 record (dead product
code with live-looking tests is exactly what a later session re-trusts). No pin (dead code; a compile fact).

**[MINOR] · App/Variorum/Variorum/Features/Settings/DataSafetyCopy.swift:92+ (`runbook` → RESTORE.md) +
ProtectionCopy's phone privacy chapter · flagged stale text SHIPS with 0.10 unless the truth-check gates the
release** · Evidence (sharpening F-U1-4/F-U1-5, already flagged and routed — this is the consequence stated
concretely, not a re-flag): the runbook text written into EVERY backup folder by every run still says "Settings ▸
Encryption ▸ Change Passphrase ▸ *Forgot your current passphrase?*" (the Encryption tab is deleted in this diff),
describes today's quiet-roads model in its mode paragraphs, and its "the same ones the Protection pane's cards
show" lead is false on the shipped pane (the posture cards left with today's road — the floors are now inlined
literals). VX-379's truth-check (switch-day script step 7) is a READ in the window; a rewrite needs her words AND a
build BEFORE the release, or every 0.10 backup folder carries a recipe naming deleted UI. · Fix: the morning bundle
should treat the runbook rewrite as release-gating, not post-release wording; the pin stays the existing
byte-equality pin against `notes/DataSafetyRunbook.md` once her words land.

**[NIT] · App/Variorum/Variorum/EditorCommands.swift:563 · a stale collision-sweep comment at the Lock menu item** ·
"the only `l` chord anywhere in the app is ⌘⇧L (Save Choices as Lens)" — ⌘L (Switch Wing) exists
(`CapabilityRegistry.swift:2519`); the new table comment at :355 lists both correctly. One comment line.

**[NIT] · notes/plans/vx-329-switch-day.md §"The aside commands" · zsh fragility in a her-hands command** · the one
`mv` names `variorum.sqlite-wal`/`-shm` (may not exist after a clean quit — per-operand errors, partial move) and a
glob (`variorum-keys*.json`) that, matching nothing under zsh's default `nomatch`, aborts the WHOLE `mv` with
"no matches found" (nothing moves, easy to misread at 8 a.m.). · Fix: one note line in the script ("if a name is
missing, move the rest; the glob must match — it will on a 0.9.8 store"), or split into per-file `mv -f` lines.

---

## DISPOSITION NOTES (checked, deliberately NOT findings)

- **P-VX329-U1-3 (the far leg rides only a container-writing run):** traced; worst case the picked folder waits ≤ the
  24 h container interval; recorded provisional, bundled. Not re-flagged.
- **F-FL-2 (the crossing's catch reads a missing library file as past-the-swap):** traced in
  `ProtectionCrossingActs.swift:242–249`; reachable only if the slot's file vanishes under an open library; already
  flagged for a ticket at closeout. Concur: ticket, not this phase.
- **F-U3-2 (two processes over one scope still race):** true; today's posture forbids the pairing by rule. Concur
  with routing (a ticket or a CLAUDE.md line).
- **F-U3-3 (`AuthTokensStore.keychain.save` drops the write result):** verified in `performRefresh` (`store.save(next)`
  unchecked); fail-visible, never destructive; pre-existing. Concur: ticket-or-not, the orchestrator's.
- **The Mac full-suite green (5085/889) predates the phone leg's ProtectionWords edit:** the headless harness
  re-covered the words pins (386/65 + the byte-identity probe) and the record names the post-ladder CLOSING full Mac
  run as the re-cover of record — that run must actually happen before closeout; listed here so it cannot drop.
- **Send Library's new pair shape (P-VX329-U1-1), the sync row's `Account…` doors (P-VX329-U1-4), the Account
  sheet's one-segment picker (F-U1-7), Delete Account's `String(describing:)` error (F-U1-8), the single-line words
  field (P-VX329-R1-4):** each correctly bundled for the orchestrator/her; the builds match the recorded options.
- **SurfaceContracts/AppSpec §12 still say "Release road until VX-329" / "Debug builds only":** the phase is open;
  these are MERGE-MOMENT deltas under the two-file rule. For the closeout's list: AppSpec §12 (portability line +
  protection line), SurfaceContracts Doors (both sections), AppSpec §7 `sync_state` comment (the MINOR above),
  AppSpec §7's "local-only sync machinery" is otherwise already true, SyncSpec §12's running record gains the
  marker-14 entry at the deploy.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The flip** (`ProtectionRoad.live(debug:) → true`, `opensOnTheNewRoad` deleted with its discrimination): minimal,
   pure-function-kept, pinned on both platforms (`ProtectionRoadSwitchTests:22–23`, `MobileProtectionRoadTests:27–30`
   — both arms asserted true).
2. **The Sync/ carve (L1, Fable territory):** `CorpusRotation.swift` deleted whole; NOTHING writes `RotationMarker`
   anywhere any more (swept myself); the rekey guards removed from push/pull/janitor were readers of a marker with
   no writer — dead guards, not protection (a pre-design store never reaches the engine: the road refuses it before
   open; new-road vault replacement is one CAS write, rotation retired by artifact 17); `pullIgnoringMarker` folded
   into `pullRound` WITH the VX-314 account-binding gate preserved for both `pull()` and `pullToHead`;
   `visibilityHorizonMillis` kept as the served A5 authority; `SyncError.accountRekeyIncomplete` case + description
   + its one face arm all gone together. SyncSpec §4/§5/§12 posture (outbox intact, cursor unmoved, refusal grammar)
   untouched.
3. **L0 lockstep:** `SyncSchema.lockstepVersion` 14 + `17_phase_vx307_vault.sql` registered in
   `AuthRLSDDLTests.lockstepFiles` in one commit; the marker-aware DDL pins and the new
   `theMarker14VaultDoorRetiresRotationAndLandsTheModeShape` pin re-run green by me (78/78). The branch's
   marker-14-speaks-only-to-the-throwaway consequence and the no-/Applications-refresh hold are recorded and honored.
4. **U3 one refresh authority:** exactly ONE product `AuthSession(` construction (`AppBootstrap.authority`,
   composition pin re-read by me — it walks all three product source trees, strips comments, and pins
   `mints == ["AppBootstrap.swift": 1]`); both roots hand `auth: bootstrap.auth`; the road's every composed system
   rides it (`RoadInputs.live` → `ProtectionSystem.live(session:)` REQUIRED → `WireVaultLeaf.live(session:)`);
   `FollowingSessionProvider` gone (file + references); test worlds ride `NobodySignedIn` with byte-identical
   refusals; the actor's single-flight + post-await adoption guards read correct (sign-out terminal, superseded
   sign-in wins); the revert-only accessors from the behavioral revert are GONE from the tree. R-U3-5's
   lock-memory call checked against CastleRules: no rule names the account sign-in among what a lock forgets, and
   the Keychain item (`WhenUnlockedThisDeviceOnly`, no ACL) was process-readable through a lock anyway — no
   boundary crossed.
5. **VX-462 (custody-adjacent, read line-by-line):** the fix drops the own words lock ONLY where the master's
   twelve-words copy is written, and the copy provably holds the typed words (set-up mints the vault FROM them; a
   join verifies them AGAINST the vault before `locks` are built); `opensWithTheWords` holds through
   master+copy (`KeyFile.swift:291`); the no-copy arm keeps the old behavior; backups' frozen key files and rules
   4/5's floors untouched (no key change on the non-rekey join); the two flipped pins' semantic move ("nothing is
   replaced" read as her words still opening, not as wrap bytes) is recorded with the lifecycle fixture untouched;
   the re-keying roads' same shape correctly routed as F-R1-4 (a ticket).
6. **VX-461:** mechanism traced end-to-end and believed (ATTACH creates the granted path; the copy's first write
   opens `<picked>-journal`, outside the one-path grant; `application.sb` carries no SQLite related-file rule);
   the fix (`PRAGMA plain.journal_mode = MEMORY` after ATTACH, before `sqlcipher_export` and the DROP/DELETE writes)
   is the narrowest correct one; never-overwrite guard and backups-folder refusal untouched; pin + export suites
   re-run green by me. The walk's live row is correctly owed to the stage batch.
7. **The classifier (R-U1-2 / piece 5):** names a key-file-shaped file by NAME in a FIXED order, reads no byte;
   `.bareStoreWithoutKeyFile` reserved for truly bare; the pre-design pins re-run green by me;
   `PreDesignStoreRefusalTests` pins the live slot's rule-27 refusal + the picked copy's honest sentence, and
   correctly records (not invents) that neither face names the way out — matching the OPEN DESIGN NOTE's demand and
   bundling the naming question for her.
8. **The backup rewrite (R-U1-5):** the pair road is the one writer (`ProtectionBackupHook.attach`/`runPair` →
   `takePairReporting`); due-ness is the catalogue's per-library-per-Mac-per-place read (`OwnCopies.pairIsDue`,
   `farPairIsDue` delegating), never the folder's newest file; `farInterval == StoreBackup.Configuration().interval`
   pinned; retention's 14+4 single home in core; Data Safety counts the catalogue's pairs with paths/set-states as
   read; the single-flight run door and the trusted-stamp rule kept.
9. **Relocations byte-checked by reading:** `PassphraseWrap` (same `kdf`/`wrapped` coding keys), `KeyFingerprint.of/
   .short`, `StoredAppleKey` (`{id,key}`), `ProtectionKeychain.sharedGroup` (team prefix + suffix), `IdleLockClock`,
   `WordsInput.words(from:)` claim, `WhatsNewLedger` (diff shows an exact move + the one new parameter),
   `VaultRewrapFormatTests` (the surviving subject's suite moved whole). The envelope's two error cases re-homed on
   `KeyFileError` (`unreadable`, `emptyPassphrase`).
10. **The sweep table spot-checked:** 11 deleted symbols re-swept by me (`PostureSwitch`, `EncryptionSession`,
    `StoreKeyEnvelope`, `LibraryOpenModel`, `StoreLaunchGate`, `CorpusRotation`, `RotationMarker`,
    `accountRekeyIncomplete`, `DeviceKeySyncProvider`, `SyncCustodyRecord`, `adoptLibrary`) — zero live-code
    references outside the recorded fixture lines; the Mac app test tree COMPILES at the review tip (my own
    `build-for-testing`).
11. **The riders' seams:** VX-464's `typesTheAccountsSecret` discriminates exactly the vault-checked doors (join
    where a vault exists + Move; follow and set-up keep "this library" — rule 7/14 consistent); VX-469's line rides
    both entering confirms through the sentence lists (sheets render lists as given); VX-473's fact reads the OPEN
    library's record live, re-read at the landing hook and pane appearance, with nil-keeps-shipped-wording;
    VX-468's ledger spends the process ticket without recording (next launch shows), creation deliberately excluded
    as P-VX329-R1-3(a); VX-463's eight sites all render `PeekableSecretField` (re-greped), the shared field's
    conceal-on-clear and privacySensitive read correct.
12. **The switch-day script's step 4 traced against the code** (the one step I could falsify): her real container
    carries NO `variorum-library-lived-here` marker (only the NEW road's leaf writes it), so after the aside
    commands the route reads `storeFile == .absent`, `containerMarker == false` → `.startFresh` → the calm first
    open mints a fresh library with no face in front — the script's sentence is right. (On a container where the
    new road HAS lived, the same state would land the three-door missing face — worth knowing, not a defect.)
13. **The fix legs:** the six Mac reds' dispositions verified against the code (the inline `PlantedRoad()` lifetime
    mechanism is real — `TempSlot.deinit` removes the slot; the fix holds the road per test with no expectation
    changed; F-FL-1's crash fixed test-side with `@MainActor` on the suite, the product's isolation kept); the
    phone leg's six re-worded sentences ride `ProtectionCopy.deviceName` with the Mac byte-identical (probed in
    their harness; the words-file idiom), the 22 exemptions carry reasons and a one-match cap, and the two unspoken
    receipts' re-word-not-exempt call is the right direction (VM-8 would have been blinded).
14. **pg_temp artifact content:** strict per-signature alters (no pg_proc loop), lists preserved with `pg_temp`
    appended LAST, the marker-14 guard, the fail-loud verify, read-only tail; `sync_reencrypt` correctly absent;
    `rls_auto_enable` carried with its own `pg_catalog` list. The rehearsal's read-fix-re-run story is consistent
    with the artifact's own comments.
15. **The site delta brief:** read against CastleRules — the one sentence, rules 4/5/7/11/12/15/16/17/18/21/23/25/26/27
    all faithfully rendered; the superseded facts (anchor, salted hash, Opens-with, Re-link, shared Apple key) are
    gone; the VX-213 deletion-log facts carry their own checked-against-docs caveats and tell the site agent to
    source retention numbers from Supabase's current docs, not this brief.
16. **No violations of the absolute classes:** nothing tracks word-level change, nothing copies text across
    entities, nothing in the diff scales with corpus size (the classifier's staged copy and the export are
    deliberate one-shot doors, recorded); triggers untouched; schema untouched locally (marker-only); S1–S5
    untouched; I1–I10 untouched; rule 24 honored (release floor recorded green twice; debug floor re-run by me —
    see below).

**Full core debug suite at the review tip (my run):** see the appended result line below.

*(Findings file complete pending the full-suite line; the final message to the coordinator summarizes this file.)*
