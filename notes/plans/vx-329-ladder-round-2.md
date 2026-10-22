# VX-329 — ladder round 2 (cold review, Fable, 2026-10-22)

**Reviewer:** fresh `fable-reviewer`, zero implementation context, REVIEW_PROMPT verbatim; round 2's job per the
ladder rules — re-review the round-1 fixes against their findings, and sweep everything landed since round 1's read
(`ffde7c67a..92e052feb`: the record fixes `2240a7f19`, the fix leg `d438050f9..de6b8a9b2`, the Sync/ carve
`e7e4d07d9`, the RESTORE.md landing `d8c9df6b2..543645f53`, the rule-27 amendment `8a369f4c5`, the morning sitting
record `92e052feb`).
**Canon read in full, myself:** CLAUDE.md + auto-canon · `notes/CastleRules.md` whole (rule 27 as amended) ·
`notes/SyncSpec.md` whole · the plan whole (incl. §7, the sitting record, all unit records) ·
`notes/plans/vx-329-ladder-round-1.md` (findings + the reviewer's final calls) ·
`notes/plans/vx-329-ladder-round-1-fixes.md` · `notes/plans/vx-329-switch-day.md` whole ·
`notes/stargazing-castle-rebuild-delta-brief.md` · `notes/DataSafetyRunbook.md` whole.
**My own verification runs (headless):** `swift test --filter StorePlaintextExportTests` 4/1 green;
`swift test --filter "everyDefinerPathEndsInPgTempOnceTheBeltIsRead|aDoctoredChainIsFlaggedByTheSearchPathCheck"`
2/1 green; an independent system-sqlite3 probe of the `-shm` discrimination (scratchpad — planted
`-wal`/`-shm`/`-journal` beside a zero-page attached pick: `-wal` GONE, `-journal` GONE, `-shm` SURVIVED
byte-identical, exactly the dispute's mechanism); a byte-equality reconstruction of `DataSafetyCopy.runbook`
(interpolations substituted) against `notes/DataSafetyRunbook.md` — **BYTE-EQUAL: True**; the full core debug
suite at the tip (result in the clean bill).

---

## HALF 1 — EACH ROUND-1 FINDING'S FIX, AGAINST ITS FINDING

- **The MAJOR (the switch-day script's REHEARSED claims vs the missing §8 record) — CONFIRMED-FIXED on its honesty
  half** (`2240a7f19`): every REHEARSED mark is now REHEARSAL-PENDING with the flip condition stated twice ("flips
  only when the plan's §8 rehearsal record exists"); the §2 paragraph and the closing bullet both carry it; the
  pg_temp step now points at the plan's PG_TEMP REHEARSAL RECORD (which exists) instead of a bare REHEARSED. The
  honesty fix landed (10:56) BEFORE her sitting read (12:15+), so the script reached her hands honest. **The §8
  record itself remains OWED before the pause completes** — correctly sequenced (the §7 rehearsal plan runs one
  stage window after this ladder closes); not a new finding, the standing obligation restated so it cannot drop.
  Residual NIT below (the step-0 "7/7 cmp-identical" staging claim).
- **Finding 1 (the export's sidecar sweep) — CONFIRMED-FIXED, and the dispute's resolution VERIFIED INDEPENDENTLY.**
  The round-1 reviewer's own `-wal` pin was withdrawn as hollow; I re-proved the counter-mechanism myself with the
  system sqlite3 (3.54.0): beside a zero-page attached database, a planted `-wal` and `-journal` are deleted by
  SQLite's own pager conventions at the first statement (journal_mode=MEMORY included) while `-shm` survives — so
  only `-shm` discriminates the sweep, exactly as the implementer's dispute claimed. The pin of record
  (`StorePlaintextExportTests.aStrangersShmBesideThePickSurvivesTheExport`) asserts survival byte-identical; red on
  old recorded with revert check; the fix (`da778d459`) deletes exactly the four sweep lines with an honest comment;
  green at the tip in my own run. The stranger-`-wal`/`-journal` consequence stays routed as the ruled Low ticket
  (F-FL-R1-3) — concur.
- **Finding 2 (the pg_temp belt's drift pin) — CONFIRMED-FIXED** (`deee7fe79`). Read line-by-line: a pure resolver
  over the full deploy order (01–04 → the lockstep chain with the three function-creating maintenance artifacts at
  their deploy positions → the belt right after 17 → every later lockstep file after it), per exact normalized
  signature, dollar-quoted bodies masked, fail-loud on an unreadable create; `create or replace` correctly RESETS
  the SET clause (the drift class); alters must target a live signature (furniture exempt, reason as data) and
  preserve the list in force with `pg_temp` appended last. The bite proofs cover the belt unread (all 18 flagged),
  a doctored later re-create of `key_vault_update` (flagged by name, nothing else), a self-carrying future definer
  (clean — not over-eager), a dropped `extensions` entry, a typo'd overload (both sides flagged), and the emptied
  furniture list (exactly `alter-unknown:rls_auto_enable()`). Red-on-old by behavioral revert recorded
  (the belt's registration line removed → the real arm red). 2/2 green in my own run. This fully answers the
  finding's drift mechanism.
- **Finding 3 (`Crypto/VaultBootstrap.swift`) — CONFIRMED-FIXED** (`a51a76adc` + the orchestrator's carve
  `e7e4d07d9`). `VaultBootstrap` + its suite deleted; residue swept by me: zero references anywhere but one honest
  history comment in `Package.swift`. `VaultEnrollment` KEPT with the keep recorded and its doc rewritten true
  (today's callers are the core's test worlds — `VaultEnrollmentTests`, `AccountLifecycleTests`' world,
  `ScriptedVaultServer`; verified by my own grep). **The Sync/ carve (Fable territory, my full judgment):**
  `e7e4d07d9` deletes exactly `StaticSyncKeyProvider` (`SyncEncryption.swift:114–128`), a caller-less public
  conformer of `SyncKeyProviding` — zero references remain anywhere (`rg --word-regexp` over Sources/App/Tools/
  Tests/Package.swift: exit 1); `UnenrolledKeyProvider` and `SyncKeyProviderError` untouched; no engine line, no
  behavior, no schema. A clean carve honoring the fence; nothing more it should have taken.
- **Finding 4 (the stale collision-sweep comment) — CONFIRMED-FIXED** (`cdfa36076`). The comment now names ⌘L
  (Switch Wing) and ⌘⇧L (Save Choices as Lens); I re-swept the key table and the `.keyboardShortcut("l", …)` call
  sites — exactly three `l` chords (⌘L :228/:523, ⌘⇧L :270/:799, ⌃⌘L :358/:570), the comment true.
- **The checklist MINOR (the grant-sweep row) — CONFIRMED-FIXED** (`2240a7f19`): the Verify row now reads
  **62 OK · 4 INFO · 0 fail** with the R-2 marker-aware reason stated; no second count survives in the file.
- **The L1 canon-note MINOR — CONFIRMED-FIXED** (in the plan's L1 record): the note now aims the closeout delta at
  **AppSpec §7**'s `sync_state` DDL comment and names SyncSpec §3's pre-existing `device_id` staleness beside it,
  one line each in its own file per the two-file rule.
- **The runbook MINOR (stale RESTORE.md ships with 0.10) — FIXED IN SUBSTANCE, WITH GAPS (the gaps are this
  round's findings 1 and 2 below).** The rewrite landed at her approval (`543645f53`); the shipped text no longer
  names deleted UI (the Encryption tab's door is gone; "Reset forgotten passphrase" is the named door and exists);
  the three-way agreement holds (literal ↔ repo doc byte-equal, reconstructed and proven by me; the draft record
  agrees); her edit-pass claims verified (no shouty caps, no temporal framing, the ops-history line gone, §4's
  Look-inside pointer present, "None of this", the floor naming both secrets). BUT the landing left five standing
  Mac pins quoting the pre-rewrite text (finding 1 below) and two of its new factual claims do not match the
  shipped build (finding 2 below).
- **The zsh NIT (the aside mv) — CONFIRMED-FIXED** (`2240a7f19`): per-file `mv` in a `for` loop, `[ -e ]`-guarded,
  the glob carrying zsh's `(N)` qualifier so an empty match is legal; the comment says why. Correct zsh.

## NEW FINDINGS (severity-ranked)

**[MAJOR] · App/Variorum/VariorumTests/DataSafetyTests.swift:266–268, 293–294 · the RESTORE.md rewrite landed
without flipping the five standing pins that quote the OLD runbook text — two Mac tests are RED at the tip, and the
landing commit's evidence line claims the suite green** · Evidence (each string grep-proven ABSENT from the
rewritten `DataSafetyCopy.runbook` / `notes/DataSafetyRunbook.md`, which are byte-equal):
`sectionEightIsComposedFromTheProtectionBrainAndClaimsNothingStale` expects
`"**Standard** — the floor: you lose your writing only if you lose every Apple device"` (:266),
`"**Castle** — the floor: lose every enrolled device and both your passphrase and your twelve"` (:267) and
`"Nobody can help — not Apple, not us."` (:268) — her rewrite replaced the two posture-card floors with the one-
sentence floor and re-worded Castle's line ("Nothing else opens it, by design — not Apple, not us.");
`theRunbookCoversWhatItsTableOfContentsPromises` expects `"A PEER, not a backup"` (:293 — her no-shouty-caps edit
made it "A **peer**, not a backup") and `"recovery phrase"` (:294 — the rewrite says "twelve words" throughout,
which `U2WordsTests.retired` elsewhere REQUIRES of road copy). The pin file was last touched at U1 (`e52f3f275`),
before the rewrite; U1's own comment at :263–265 deliberately pinned the old floors "as the cards last said them
… the runbook's rewrite … is hers" — the tripwire fired exactly as designed, and the fix leg never ran it.
Mechanism: `xcodebuild test` on `VariorumTests/DataSafetyRunbookTests` at the tip → 5 failing expectations in 2
tests; the post-ladder CLOSING full Mac run (the re-cover of record, round 1's disposition note) fails. The
`543645f53` commit message's "the runbook pin suite green (exit 0)" cannot be true of this suite on a coherent
build — a verification claim the tree contradicts. · Fix (the implementer's): rewrite the five expectations to pin
the APPROVED text's load-bearing claims as justified edits (the suite's own R-13s-37 precedent) — the new one-
sentence floor (`"your passphrase or your twelve words — together with any copy of your library — always open
it."`), Castle's `"not Apple, not us"` as now worded, `"A **peer**, not a backup"`, and the twelve-words vocabulary
in place of "recovery phrase" (keep :259–262 and :272–273's absence arms; they still pass and still bite). The
red-on-old is the CURRENT red — no new pin owed; the re-run is the closing Mac batch's
`-only-testing:VariorumTests/DataSafetyRunbookTests` plus the closing full run. Product text changes: NONE (the
approved words stand).

**[MINOR] · notes/DataSafetyRunbook.md §2 + §3.1 (= DataSafetyCopy.runbook, byte-equal) · two NEW factual claims in
the rewritten runbook do not match the shipped build** · Evidence: **(a) the cadence comparative** — "One copy a
day lands there; the ones beside the store run more often." Both legs read the SAME 24-hour interval:
`StoreBackup.Configuration.interval = 24 * 60 * 60` ("launch + daily"; the hourly tick is a due-CHECK, not a copy)
and `ProtectionBackupHook.farInterval = 24 * 60 * 60`, pinned equal at `DataSafetyRoadCountsTests:125`; the far leg
can only run less or equally often (P-VX329-U1-3: it writes only on a run that writes the container's). The Data
Safety pane's own shipped sentence says the true thing — "Variorum copies your library once a day while it is
open" (`DataSafetyPane.swift:132`) — so two shipped texts now disagree and the runbook's is the wrong one
(it implies sub-daily beside-the-store copies, understating the up-to-24h loss window in a data-safety document).
**(b) the per-row opens claim** — "Restore from Backup lists your copies, newest first, and each row says what
opens it." `CopyDoorRow` carries copy · isThisLibrary · asOf and nothing else; the sheet renders no opens line
(grep over `CopyDoorsSheet.swift`); what shipped is rule 5's ONE sentence on the pane
(`ProtectionWords.dataSafetyWhatOpensABackup`, `DataSafetyPane.swift:144`) — exactly the considered-and-not-pursued
reduction ("the 'Opens with' route finder as a promise — reduced to one sentence"). Both sentences are NEW in this
rewrite (absent from the pre-rewrite doc — provenance checked at `543645f53^`). · Fix: two one-clause word
corrections (e.g. "One copy a day lands in each place" / "…lists your copies, newest first; what opens a backup is
said below the list"), applied to the byte-equal trio (literal + repo doc + draft record) — her words, so the
corrected sentences go through her (the morning bundle) before or at the closing re-run; the byte-equality pin
keeps the three together. No pin owed beyond the existing byte-equality and (for (a)) the standing interval-equality
pin — doc-accuracy class, traced above.

**[MINOR] · notes/stargazing-castle-rebuild-delta-brief.md:89–90 · the delta brief still carries rule 27's
SUPERSEDED sentence** · Evidence: the brief's "What if every copy is gone?" entry reads "Synced libraries are the
exception: the twelve words recover them from the account." — the pre-amendment text; `8a369f4c5` (her morning
ruling: "the account's passphrase or twelve words") updated CastleRules + the two quoting code comments but not
this brief, which is this phase's OWN rewritten deliverable (F-U2-4), staged for the site agent, whose header
promises "the VX-329 window re-checks each fact against the shipped build". Mechanism: the site agent publishes
the incomplete sentence (understating the passphrase road) on the public help page. · Fix: one line — align the
entry to amended rule 27; it rides the window's fact re-check, but landing it now costs nothing. Doc-class, no pin.

**[NIT] · notes/plans/vx-329-switch-day.md step 0 · the "ALREADY STAGED (7/7 cmp-identical)" claim remains
self-recorded only** · Round 1's MAJOR named it in evidence; the fix clause carried only the REHEARSED marks and
the §8 pointer, so this clause still has no record outside the script's own sentence (the folders exist on disk —
round 1 verified — but the cmp result is point-in-time and now unverifiable, since her live store has moved).
· Fix: when §8's rehearsal record lands, carry the staging row in it (date, file count, the cmp command's shape);
one paragraph.

**[NIT] · Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/LifecycleProse.swift:89 (+ the rendered
castle-lifecycle.html) · the lifecycle page's never-list drops rule 27's exception clause** · "What we don't
promise: … Recovery of a library whose every key-file copy and every backup are gone [27]." — rule 27's second
sentence (synced libraries recover from the account) is a promise the page's blanket line reads over.
PRE-EXISTING (the exception predates this phase; the amendment only widened it), so not this diff's — recorded so
the closeout's rulings-reconciliation sees it. Fix if wanted: one clause in the fixture ("— synced libraries
excepted [27]") and a regeneration; hers to want.

## DISPOSITION NOTES (checked, deliberately not findings)

- **The fix leg's evidence counts reconcile exactly:** debug 3288/429 = round 1's 3298/430 − VaultBootstrapTests
  (13 tests, 1 suite) + the leg's 3 pins; release 3259/424 likewise. The MCP flake sightings (incl. the new
  `MCPSetupKeyServerTests` release sighting, F-FL-R1-1) stay routed to the closeout ticket — concur.
- **The morning sitting record's claims verified against the tree:** the testers' line rewritten to her timing
  truth (the script's §"beta testers' line" says the sync-once window closes at HER deploy and names Copy full
  text, never 0.9.8's broken export door — consistent with VX-461 shipping only in 0.10); the ops-history line
  gone (`237a5f7fe`, grep-clean); rule 27 amended in place with the two quoting comments (`8a369f4c5`); the
  sealed-copy answer matches `EnterCastle.afterCommit`'s "memory" step (`rememberNewKey` at Castle entry); the
  refusal-face and VX-465 rulings are record-only.
- **The runbook's other facts checked against the code and found true:** the pair naming
  (`variorum-backup-<yyyy-MM-dd-HHmmss>[-<fp8>].sqlite` + `.keys.json`, UTC, lexically sortable —
  `CatalogNames`); `Backups/<library8>/<mac8>/` per-library-per-Mac nesting; `<picked>/Variorum/Backups` and
  `<picked>/Variorum/md-exports` (`BackupDestination.variorumFolder`, `MarkdownInsurance.folderName`); retention
  14 container / 14 dailies + 4 weeklies far (`Retention.Policy.standard`) with the never-touch-others fence;
  md-exports weekly, keep 4 (`MarkdownInsurance.Policy`); the md-export carries takes (the Alternates sections),
  tags and one file per book, and no commits/comments/book settings (`Queries/Export.swift`); the Trash's 30 days
  (the purge road's clock); the iCloud Drive first-backup offer; export-off-with-notice at Castle entry
  (`EnterCastle.afterCommit`'s "exportOff"); every door name the runbook uses exists with those words (Make this
  my library · Look inside · Restore from Backup · Resume Sync · Reset forgotten passphrase · Replace All Keys ·
  Sign Out Everywhere · Copy full text · Open Library… · Previous Libraries · New Window); §8's floor is amended
  rule 27 verbatim-in-substance. The "7 days of server backups" line is carried over from the pre-rewrite doc
  (external fact, unchanged this phase; the delta brief already tells the site agent to source retention numbers
  from Supabase's current docs).
- **"Dropped beside your library and into every backup folder":** the writer drops `RESTORE.md` at the container
  `Backups/` root (the place the Data Safety face itself calls "beside your library") and at `<picked>/Variorum/`
  — one copy per destination root, not per `<library8>/<mac8>/` leaf. Read as the destinations' roots the sentence
  is true; not flagged.
- **The switch-day script's `(N)` glob fix is correct zsh** (bare glob qualifiers are on by default in zsh; the
  non-glob operands are `[ -e ]`-guarded per file).
- **No other suite quotes the rewritten runbook:** the only other `DataSafetyCopy` reader is
  `TutorialWalkTests:2171` (`secondFolderSection`, unchanged); the old-text sweep (`A PEER`, `recovery phrase`,
  the floors, `Nobody can help`, `Forgot your current passphrase`) hits nothing outside `DataSafetyRunbookTests`.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The Sync/ carve `e7e4d07d9`** — a pure deletion of a caller-less `SyncKeyProviding` conformer; zero residue;
   no engine, schema, trigger or repair line near it; the fence's letter and spirit both honored (my own sweep).
2. **The `-shm` pin's discrimination** — independently re-proven mechanism (system sqlite3 probe: `-wal`/`-journal`
   deleted by the pager beside the zero-page pick, `-shm` kept); the withdrawn `-wal` pin was indeed hollow; the
   pin of record is red-on-old by the recorded revert and green at the tip in my run; byte-identity asserted.
3. **The pg_temp drift pin** — the resolver's deploy order matches the real chain (incl. the three maintenance
   artifacts' positions and later-files-after-the-belt); the bite proofs doctor both directions (missed belt,
   later bare re-create, list drift, unknown signature, furniture); `sync_reencrypt`'s drop is seen; 18+ checked
   non-vacuously; green 2/2 in my run.
4. **`VaultEnrollment`'s keep** — recorded, doc-true, and real (three live test-world consumers verified).
5. **The runbook byte-equality** — reconstructed the interpolated literal myself: byte-equal to
   `notes/DataSafetyRunbook.md`; the three shared warning sentences (M2–M6) ride unchanged, so no app face moved.
6. **Rule 27's amendment** — canon + both quoting comments updated; the repo-wide quote sweep finds only the two
   stale spots named above (the delta brief MINOR; the pre-existing lifecycle NIT); the runbook and the lobby's
   account line already speak the amended truth.
7. **The switch-day script at the tip** — honest throughout: REHEARSAL-PENDING gated on §8, the pg_temp step
   pointing at its real record, the grant-sweep count matching the checklist's corrected row, the testers' line
   hers, the aside commands zsh-safe, step 4's fresh-slot behavior consistent with the route code (round 1's trace
   stands).
8. **The record fixes changed no code** (`2240a7f19` is notes-only), and the fix-leg commits touch exactly the
   files their records name; the fence (`git diff 2240a7f19..HEAD -- Sources/VariorumCore/Sync` = the one carve
   commit by the orchestrator's own hand) held.

**Full core debug suite at the review tip (my run, 2026-10-22):** VariorumCoreTests **3288 tests in 429 suites
PASSED** (208 s — the fix leg's recorded floor exactly); StringsWorkbook **32/4 PASSED**. (The MCP target's summary
line scrolled out of my capture window; the target is untouched by this whole phase and its load-flake family is
already routed to the closeout ticket — F-R1-6/F-FL-R1-1.)

---

**ROUND 2: one new MAJOR (the stale runbook pins — two Mac tests red at the tip), two new MINOR, two NIT; every
round-1 finding's fix otherwise CONFIRMED. By the ladder rule the new MAJOR earns round 3 — its fix is test-side
only (five expectations made true to the approved text; the approved product text stands), so round 3's re-check is
narrow: the flipped pins, the closing Mac run's `DataSafetyRunbookTests` result, and the two MINOR word corrections
if she lands them.**

---

## ROUND-2 FIX LEG (Opus implementer, 2026-10-22) — the MAJOR only

**Not done by this leg (stated first):** no `xcodebuild test` run (out of this leg's limits by the brief — the
orchestrator's closing Mac run, `-only-testing:VariorumTests/DataSafetyRunbookTests` plus the closing full run, is the
re-cover of record); the two MINORs (the cadence comparative and the per-row opens claim — her words, routed to her
bundle) and the delta-brief MINOR and both NITs are untouched; zero product edits (the `DataSafetyCopy.runbook`
literal, `notes/DataSafetyRunbook.md` and every product file byte-unchanged); nothing under `Sources/VariorumCore/Sync/`.

**LIVE STATUS**
- The five flips in `App/Variorum/VariorumTests/DataSafetyTests.swift` — DONE (this commit).
- Compile evidence (`swift build` headless + `xcodebuild build-for-testing` from `App/Variorum/`) — **PENDING** (flips
  in the next commit).

**The red-on-old is the CURRENT red** — no new pin owed (the finding's own disposition). Its mechanism, re-proven by
me before the edit: each of the five old expectation strings occurs **0** times in the runbook literal
(`DataSafetyCopy.swift` lines 92–288) and **0** times in its byte-equal twin `notes/DataSafetyRunbook.md` (`grep -c -F`
per string), so `sectionEightIsComposedFromTheProtectionBrainAndClaimsNothingStale` (3 expectations) and
`theRunbookCoversWhatItsTableOfContentsPromises` (2) fail at the tip `6882f89b8` exactly as the finding says.

**The flips (justified edits — each new expectation quotes the approved literal exactly, wraps included):**

| Line | Old expectation (absent from the literal) | New expectation (the approved text's own claim) |
|---|---|---|
| :266 | `**Standard** — the floor: you lose your writing only if you lose every Apple device` | `**your passphrase or your twelve words — together with any⏎copy of your library — always open it.**` — the ONE floor (literal :285–286) |
| :267 | `**Castle** — the floor: lose every enrolled device and both your passphrase and your twelve` | `A library whose every key-file copy and every backup are gone is gone;⏎synced libraries are the exception — your account's passphrase or twelve words recover them from the account.` — amended rule 27 whole, the loss leg and its exception (literal :286–287) |
| :268 | `Nobody can help — not Apple, not us.` | `Nothing else opens it, by design — not Apple, not us.` — Castle's line as now worded, message "never softened" kept (literal :283) |
| :293 | `A PEER, not a backup` | `A **peer**, not a backup` — her no-shouty-caps edit (literal :131) |
| :294 | `recovery phrase` | `Your passphrase and your twelve words do not encrypt anything themselves` — the same §8 sentence that once glossed "(the recovery phrase)", now in the twelve-words vocabulary, still naming the two roads the comment promises (literal :275); "recovery phrase" is a retired word (`U2WordsTests.retired`) |

(⏎ = the literal's real line break, written `\n` in the Swift pin.) The arms the finding said to keep — :259–262 and
the 13s-b absence arms — are untouched and still hold (each string `grep -c` 0 in the twin); the eight headings and
"Always copy out as new" each occur once. The U1 comment above the floors is rewritten true (the composition retired
at U1; her rewrite's one floor); the test's NAME still says "ComposedFromTheProtectionBrain" — historical, left as is
(a rename would be outside this leg; noted for the closeout if wanted).

**Byte proof** (`r2fix_byteproof.py`, scratchpad): rebuilds the literal from the Swift source (the lines between
`static let runbook = """` and the closing `        """`, the 8-space indent stripped — 195 lines, 93..287) and counts
each new expectation, exactly as Swift evaluates it, in the rebuilt literal and in `notes/DataSafetyRunbook.md`: all
five **x1 · x1**; all five old strings **x0 · x0**; `ALL CHECKS PASS`. Per-segment `grep -n -F` on
`DataSafetyCopy.swift`: :285 / :286 / :286 / :287 / :283 / :131 / :275.
