# Phase 17 — Standing Fixes (STANDING PLAN)

> **This phase does not close.** It is a standing home for bug fixes and tech debt, opened by the
> author on 2026-08-30. Its **entries** (17a, 17b, 17c, …) are what open, run, and close — the phase
> itself stays open for the life of the project. A closed entry is never reopened; a recurrence gets
> a fresh letter.

## The philosophy (author, 2026-08-30 — her words)

> *"I would start a new phase, not filling the detailed plan for phases doc since we just reduced how
> full it was but just with a pointer there, and that phase will be standing quick bug fixes. from now
> on, when I notice a quick bug or issue or something that I want fixed, it'll be added as an entry
> like 17a, 17b, 17c, etc. […] bascially, I want to be able to active phase discipline and share where
> random fixes and changes are going in one cohesive phase, without it polluting the detailed plan for
> phases document with bug fixes / tech debt rather than product advancement."*

**The rule this establishes, stated plainly:**

1. **`DetailedPlanForPhases.md` is for PRODUCT ADVANCEMENT.** New capability, new surfaces, new
   design — things that change what the app *is*. It carries exactly **one pointer row** to this
   file and nothing else about fixes. This extends her 2026-08-30 lean-docs ruling (the one that
   created `notes/FuturePhases.md`) along a second axis: that ruling moved far-future work out by
   TIME; this one moves fixes out by KIND.
2. **Fixes, bugs and tech debt live HERE**, grouped into lettered entries — so they still get real
   phase discipline (a scope, a cast, tests, a closeout) instead of becoming ad-hoc side work, and so
   there is **one place to look** for where a random fix went.
3. **A 17-entry is a valid owner** under `KnownIssuesAndTechDebt.md`'s rule ("no entry without naming
   the owner that resolves it"). Naming `17c` satisfies it exactly as naming a phase number does —
   the same widening her 2026-07-26 R2-7 ruling made for project rows. **A blank owner is still
   forbidden.**
4. **THE REVIEW RULE (author, 2026-09-01 at the Act 10 correction round's sitting — R-cor-14):** an
   entry MAY run as ONE session without an orchestrator, under this file's discipline (pin before fix,
   red-on-old by behavioral revert, the record kept here by the session itself, the full suite + the
   tutorial spine as the gate, push after each commit) — **but an OPUS cold review is ALWAYS
   mandatory, and a FABLE cold review whenever the diff touches `Sync/`, custody/keychain code, or
   the editor seam** (`BlockRangeIndex` / `EditorTextView` / `PaneTextAuthority`). Her stated practice:
   mostly a few entries at a time as an ad-hoc phase under a **Fable orchestrator** (Opus alone does
   not keep records) — `notes/PhaseSizingGuidance.md` §5 has her words.
4. **This file is not a bug tracker and not a scratchpad.** An entry is a scoped, runnable unit of
   work. Something with no traced mechanism is not ready to be an entry.

## How an entry works

- **Adding one.** When the author notices a bug or names something she wants fixed, it becomes a new
  lettered entry (or joins an open one where it genuinely belongs). Her word opens it; nothing is
  added autonomously beyond recording what a sweep or a phase found.
- **Grouping.** Entries group by **shared root cause** where one exists, and by **shared consequence
  class** otherwise. A group large enough to want its own kickoff sitting should be split, not run wide.
- **Cast and review depth** are decided per entry at the author's word, exactly as at any kickoff. A
  two-line fix does not owe a three-round ladder; a credential-layer entry does. **The standing
  `Sources/VariorumCore/Sync/` Fable rider binds regardless of what any entry decides.**
- **Closing.** An entry closes with a written disposition for every item it carried — FIXED (naming
  its pin), DISMISSED AS HOLLOW (the pin passed on both sides), or DEFERRED with a named owner. An
  item that is silently dropped is a closeout defect. Anything deferred lands in
  `KnownIssuesAndTechDebt.md` with its owner.
- **Ordering.** Letters are allocation order, **not** priority. The running order is the author's, and
  entries interleave with product phases at her word.

## Standing rules for every entry

1. **PIN BEFORE FIX — no exceptions.** The hallucination guard binds here exactly as in a phase
   review: no item is fixed until whoever fixes it has **traced the mechanism themselves**, and every
   bug-class fix lands with a **red-on-old pin** — a test that fails on the pre-fix code and passes
   after. **A pin that passes on both sides exposes the item as hollow: it is dismissed, recorded,
   and NOT fixed.** Architectural and clarity items need no pin but still need the traced mechanism
   and a written justification.
2. **Nothing in this file has a pin yet.** Every item below arrived from a review, carrying a traced
   mechanism and a file:line and nothing more. Step zero for each is the pin.
3. **No product invention.** A fix that requires deciding behaviour the spec does not define is not a
   fix — it goes to `notes/QUESTIONS.md` and waits for the author. The author-only calls in
   `CLAUDE.md` bind unchanged.
4. **Measure before believing a number.** Sweep-sourced performance claims are traced-by-reading
   unless they say otherwise.
5. **Schema changes get their own commit**, ahead of anything using them, per CLAUDE.md.

---

## Allocation register (read before adding an entry)

Letters are **allocation order, not priority**, and more than one session may be adding entries at
once. Claim a letter here first.

| Letter | Subject | State |
|---|---|---|
| **17a** | **CLOSED 2026-08-30 — the pre-13u round's Act 9 (the Fable custody batch).** All 8 items FIXED with revert-verified red-on-old pins; per-item dispositions in the entry below; the two KnownIssues rows that carried owner "17a" without being in the item list are RE-ROUTED to **17h** (opened at her word) | **closed** |
| 17b, 17d, 17e | The 2026-08-30 sweep's remaining groups | open, unstarted |
| **17f** | **CLOSED 2026-08-31 — the pre-13u round's Act 5.** 8 of 9 items FIXED (each with its evidence class named: three red-on-old drills, two grep-verified dead-code removals, one hoist, one canon correction, one documented mechanism); **P50 DISMISSED AS HOLLOW by measurement** — the WAL it claimed was checkpointed away measures byte-identical before and after `lock()`. Per-item dispositions in the entry below | **closed** |
| **17c** | **CLOSED 2026-08-31 — the pre-13u round's Acts 3+4.** All 4 read-layer items (P18–P21) FIXED with revert-verified red-on-old pins (query plans and statement counts, never timings); the P20 index landed as its own schema commit and is NOT a §12 lockstep event (marker stays 7). Per-item dispositions with before/after numbers in the entry below; one residual (`container_block(block_id)`) re-routed to **12** in KnownIssues | **closed** |
| **17g** | **CLOSED 2026-08-30 — the `13p-fix` session** (author's live session of 2026-08-30: an issue she found testing the refreshed 13p install). That session owns this letter and writes its own entry; it does **not** fold into 17a. | **closed** |
| **17h** | **The custody riders 17a never listed** — opened at the author's word 2026-08-30 (the pre-13u sitting: "Open 17h, run it this round"). TWO items, both already traced in `KnownIssuesAndTechDebt.md` rows that carried owner "17a" without being in its 8-item list: **(1)** the `saveGated` delete-before-add window (13p-fix ladder R2-7 — a failed `SecItemAdd` after the forced delete leaves no custody; remedy sketch on the row: add under a temporary account → verify → swap → delete old, or an explicit accepted-window doc line); **(2)** the delete-status-discarded family (R3-5 — `deleteAuto`/`deleteGated` drop `OSStatus`, so the custody law binds writes only; remedy on the row: `Bool`-returning delete seams + refuse/report on failed release + a `deletesSucceed` knob pin; the riders travel with it: `E2EECustodyStorage.live` wiring coverage R3-4, `setMode`'s MainActor SecItem calls R3-6). The rows' mechanisms and remedies are the brief; runs as a small fresh Fable session inside the pre-13u round, after Act 9 closes. **CLOSED 2026-08-31** — both items FIXED (R2-7 as probe-first narrowing with the residual window recorded; R3-5 with all riders), every pin red-on-old by behavioral revert; the entry below is the record | **closed** |
| **17i** | **Sync across devices — the reconciliation probes, the scenario sweep, and the harness-realism fix** — opened at the author's word 2026-08-31 (the pre-13u round's tail): *"this is really hunting for bugs + discrepancies + issues in the implementation of sync across devices, so I think it's fine to have there… I want to have a more proper phase."* The brief is `notes/plans/pre-13u-memo-sync-disagreements.md` — the posture in five rules, the scenario table, and the UNSETTLED probes at its top (P1 delete-vs-edit-plus-new-take; P2 the purged-past-30-days + returner corner; P3 edit-vs-edit; P4 the production-round-shape sweep of every convergence suite). Structural item: the harness runs production's pull→push chunked round shape by DEFAULT. All `Sync/` — the standing Fable rider applies; pin before fix; a probe whose expected and actual agree is recorded, not "fixed". Not run inside the pre-13u round (her ruling). | **open** |

**Why 13p-fix is 17g and not part of 17a.** 17a is the *sweep's* 13p residue — eight findings from a
review that read the code. 13p-fix is a *tested* defect she hit in the running app, with its own plan
file, KnownIssues updates and handoff already complete. They are the same subject and adjacent in
time, but they are different work with different provenance, and a completed entry should not be
retro-fitted into an unstarted one. **Her sequencing pairs them anyway:** 13p-fix runs first, then a
session that does 17a *and* cold-reviews 13p-fix.

**Sequencing note (author, 2026-08-30): 17a runs BEFORE 13y.** It is live on the real encrypted store,
needs no user action to fire, is small, and is 13p's own residue — running it now closes that phase
properly while the layer is warm. **13x depends on it** (P1 breaks the copied-library road that
"AirDrop your library" is built on).

---

# The entries

## Provenance of 17a–17f

These six were populated on 2026-08-30 from a **proactive whole-codebase tech-debt sweep** run at the
author's instruction immediately after Phase 13p closed: 18 independent cold review lenses over the
tree, partitioned by area and by lens, each finding then put to an adversarial verifier instructed to
**refute** it by opening the real code, defaulting to refuted under uncertainty and treating any
documented-and-owned tradeoff as refuted. **65 raw findings → 50 survived → 15 killed.** 49 of the 50
were new; one already had a KnownIssues row.

**The full artifact is `notes/ProactiveTechDebtReview-2026-08-30.md`** — it holds every finding's
verbatim code evidence, the verifier's own trace, and the 15 refutations (kept so a later sweep does
not re-find them). The P-numbers used throughout this file are that document's. **That document is a
dated snapshot and is not a tracking surface** — it is never edited to reflect progress; this file
and `KnownIssuesAndTechDebt.md` carry the live state.

**Seven further findings from the same sweep went to 13u1, not here** (P16, P17, P22, P24, P25, P40,
P41) — the editor-seam O(N²) family, the churn pair, and two forked brains — because 13u1's item 5
rewrites that exact seam and fixing them elsewhere would mean fixing them twice. Their record is the
fold section at the end of `notes/plans/phase-13u-feel-and-polish.md`.

| Entry | Subject | Items | Note |
|---|---|---|---|
| **17a** | The 13p residue — key custody, at-open modes & the re-lock teardown | 8 | **CLOSED 2026-08-30** (the pre-13u round's Act 9; all 8 FIXED) |
| **17b** | Doors that lose or mis-copy her text | 6 | — |
| **17c** | The read layer's P1 debt (query-side) | 4 | — |
| **17d** | Purge, sync & bridge honesty | 5 | **The `Sources/VariorumCore/Sync/` Fable rider binds P8, P9, P28 and P31.** |
| **17e** | Correctness & honesty singles | 10 | — |
| **17f** | Dead code, canon corrections & test pins that cannot fail | 9 | **CLOSED 2026-08-31** (the pre-13u round's Act 5; 8 FIXED, 1 dismissed as hollow) |

---

## 17a — The 13p residue — key custody, at-open modes & the re-lock teardown

**Status: CLOSED 2026-08-30 — the pre-13u round's Act 9 (Fable custody batch,
commits `270bf4f…d6a4911` on `main`).** All 8 items **FIXED**, each with a
red-on-old pin verified by a faithful behavioral revert (the drill red
reproduced the traced end state in every case — the both-Keychain-items-deleted
library for P2, the tail-in-no-row loss for P3, the full 64-hex key on the
error channel for P15). The batch record is the **ACT 9 BATCH RECORD** section
of `notes/plans/pre-13u-round.md`; suite counts and environment notes live
there.

### Dispositions (per item)

| item | verdict | pin(s) | notes |
|---|---|---|---|
| **P1** | **FIXED** | `Phase13pControllerTests.reconcileNeverOverwritesAnUnreadableSidecar` | ONE seam: `StoreLaunchGate.readEnvelope` (absent / loaded / UNREADABLE); `ensuredEnvelope` THROWS on unreadable — foreign is a move, unreadable is a refusal, only true absence mints. The launch reconcile can no longer overwrite an unreadable sidecar or orphan the escrow item; the nudge stays quiet over unknown facts. |
| **P2** | **FIXED** | `…aModeChangeAuthorizesFromTheDiskNotTheCachedProjection` | `setMode`'s demanded-arm authorization is a FRESH disk read at the act (the `deleteBlock` in-transaction-precondition doctrine); the two invalidating doors (`setEscrow`, reconcile's escrow arm) refresh the projection as a belt. The old red reproduced the catastrophe: auto item nil, mode persisted. |
| **P3** | **FIXED** | `MacWillLockTests` (2 pins) | `macWillLock` factory (the `mobileWillLock` twin), wired in `VariorumApp`: the active editor's full `finalizeWork` (tail crystallized, pending cross-block compound landed) runs BEFORE the registry and the services stop. Recorded corner: only the ACTIVE editor gets the full finalize — identical to the quit door it mirrors; widening both is a design act. |
| **P10** | **FIXED** | `…aRecoveryWrapLandedDuringTheKDFSurvivesSetPassphrase` | `setPassphrase` derives the wrap FIRST (envelope-free, off-main — `StoreKeyEnvelope.makePassphraseWrap`/`adoptPassphraseWrap`, format guard kept) and reads the envelope FRESH after the derivation; every MainActor envelope writer is now an awaitless read→write, so the window is closed structurally, not narrowed. The pin's `makeKDF` hook stands in for the concurrent land deterministically. |
| **P11** | **FIXED** | `…setPassphraseRefusesOverAnUnreadableSidecarInsteadOfOverwritingIt` · `Phase13pLobbyTests.anUnreadableSidecarLobbySaysTheTrueCauseNeverTheAbsentOne` | Every envelope-writing door refuses with the true (unreadable) sentence; the lobby's ONE `deadEndMessage` brain serves both platforms' faces. Recorded corners, deliberately unchanged: `failedOutcome` stays doorless on unreadable (widening that surface is design); `verifyPassphraseAgainstStore` answers nil on unreadable (a third guard answer is design) — doc'd at the site, harmless since every write door refuses regardless. |
| **P12** | **FIXED** | `KeyedStoreTests.aPresentButUnreadableStoreClassifiesAsUnknownNeverAbsent` | `classify`: present-but-unreadable ⇒ `.encryptedOrUnknown` (nil-at-EOF distinguished from a throwing read; empty-file-as-absent pinned deliberate). No persisted mode downgrade; all classify consumers audited unchanged. |
| **P13** | **FIXED** | `KeyedStoreTests.openStoreNeverMintsOverAPresentButUnreadableStore` | The never-mint refusal fires TYPED (`keyUnavailable`) for unreadable stores — the recovery road can render; nothing lands in custody (the old red reproduced the untyped "SQLite error 14" + minted-custody dead end). Rider: `routeAndOpen`'s nil-URL `?? .absent` → `?? .encryptedOrUnknown` — recorded as unpinnable without refactoring the private URL resolution into a seam. |
| **P15** | **FIXED** | `StoreEncryptionMigrationTests.aFailedAttachNeverCarriesTheKeyHexInAnyErrorChannel` · `…redactionScrubsEveryOccurrenceOnBothChannels` | Catch-and-sanitize at BOTH key-bearing statements (`StoreKey.redactedDescription(of:)`; `RedactedKeyedStatementError` covers `localizedDescription` too, so the backup-log channel is closed at origin). The PRAGMA site is pinned pure only — that statement's failure is not drivable (SQLCipher defers key validation to the first page read); recorded, not skipped. |

**The two KnownIssues rows that carried owner "17a" without being in this
entry's item list** (the `saveGated` delete-before-add window, R2-7; the
delete-status-discarded family, R3-5): **RE-ROUTED to 17h** — opened at the
author's word at the pre-13u sitting; their rows in
`KnownIssuesAndTechDebt.md` now name 17h. Not resolved here, not orphaned.

**Landed WITH the batch (the same subsystem, the same commits):** the Act 1
review's routed findings F1 (the state-dependent custody pin, fully faked),
F4 (the `KeychainTestTripwire` — the R3-1 rule made structural), F5 (the fact
suite's header), F6 (the E2EE arm's own `wroteButUnreadable` sentence); the
R-pre13u-2 CF-12 rework (sync gate opt-in, default off, legacy gates reset);
the R-pre13u-3 #82 build (the store key device-bound via the TN3137
migration); and the R-pre13u-4/5 detection half (the `ProtectionLegs` nudge
brain + the VERIFIED-LANDED escrow observable and its Console evidence line).
Their records ride the batch record, not this entry.

*(The original 8-item briefs below are kept verbatim as the entry's record —
the finder claims, the verifier traces, and the provenance note.)*

Eight findings, and **six of them are one root cause**: `StoreKeyEnvelope.load` and
`StoreFilePresence.classify` throw typed errors that exist *precisely* to distinguish a corrupt or
unreadable file from an absent one — and every production consumer discards that distinction with
`try?`. `StoreKeyEnvelope.swift:201` states the rule about itself in a doc comment forty lines from
the code that breaks it.

**Why this is first, and why it is not merely a review finding.** These roads are live on the real
encrypted store migrated at 13p's overnight, on the machine she writes on daily. P1 needs no user
action at all: the escrow reconcile fires on every ready launch, escrow defaults ON, and the write is
an unconditional `.atomic` replace whose failure is itself swallowed by `try?`. The thing destroyed is
the **recovery phrase** — the insurance that made adopting whole-store encryption safe in the first
place. P3 is a different mechanism in the same phase's work: 13p's automatic re-lock never calls
`finalizeWork()`, so the open tail (the paragraph being typed, not yet crystallized into a block) is
dropped when the app re-locks itself.

**Two forward dependencies make deferring this actively expensive.** **13x** ("AirDrop your library")
is built directly on P1's road — a copied library folder with an incomplete sidecar *is* the promise —
so shipping 13x over this means fixing it twice. **13r** ships opt-in crash reporting, which is a
plausible new exfiltration path for P15 (the raw 256-bit store key reaching a GRDB error description)
that does not exist today.

**One honesty temper, carried from the verifier and not to be dropped when this is scoped:** for P1
the strict *destruction* case is a transient read failure (an I/O error, a permissions blip, a
concurrent replace by a backup tool). Where the sidecar is genuinely corrupt, its wraps were already
unusable, and restoring it from a backup folder still heals afterwards. What fires in **both** cases
is the false dead-end (the lobby asserting "no passphrase or recovery phrase is on file" over a
library where the file is present) and the orphaned escrow item. That is still a silent, launch-time,
no-action-required regression on the credential-insurance layer — it is simply not the case that
every instance destroys a good key.

### Items

#### P1. An unreadable variorum-keys.json is read as absent, so the next launch silently overwrites it with an empty envelope — destroying the passphrase and recovery-phrase wraps

`App/Variorum/Shared/ProtectionController.swift:159` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.85

StoreKeyEnvelope.load throws a typed `unreadable` specifically so corruption is never read as absence, but both consumers discard it with `(try? gate.loadEnvelope(...)) ?? nil` (ProtectionController.swift:159, AppBootstrap.swift:438). `ensuredEnvelope` (ProtectionController.swift:161-169) therefore cannot tell 'no file' from 'unreadable file', and only the FOREIGN branch gets the protective `setAsideEnvelope` move — the unreadable case falls through to `return (StoreKeyEnvelope(), false)`. Concrete path, no user action needed: a zero-byte or truncated sidecar (the ordinary artifact of an interrupted copy of the library folder, a half-finished restore from a backup folder, or a transient read error) decodes as `unreadable` because fileExists is true, Data(contentsOf:) succeeds and JSONDecoder throws. AppBootstrap.finish fires `protection.reconcile()` on every ready launch (AppBootstrap.swift:351-353); with the escrow dial ON, reconcileEscrowOffMain (ProtectionController.swift:488-493) calls ensuredEnvelope, sees `!ensured.onDisk`, and runs `try? gate.saveEnvelope(envelope, ...)` -> StoreLaunchGate.live's `try $0.write(at:)` -> `data.write(to: url, options: .atomic)` (StoreKeyEnvelope.swift:221), an unconditional replace. The fresh envelope carries a NEW random storeID, so `guardSeam.loadEscrow(envelope.storeID) != key` is true and a new iCloud escrow item is written, orphaning the old one. After one launch the passphrase wrap and recovery wrap are gone, the twelve words the user wrote down open nothing, and the `try?` even discards a write failure. Two further roads reach the same replace: refreshEnvelopeFacts (:124-128) sets hasPassphraseWrap/hasRecoveryWrap false from the swallowed nil, so resetPassphrase refuses with 'No passphrase is set yet — use Set a Passphrase instead' (:229) and StandardNudgePolicy (:529) raises the set-a-passphrase nudge — both steering into setPassphrase -> ensuredEnvelope -> saveEnvelope. Third consequence at launch under a demanded mode: passphraseOffered/recoveryOffered come from the same swallowed nil, so StoreLobby.noRoadExists (StoreLaunchGate.swift:172) is true and StoreLockView renders `deadEnd` (StoreLockView.swift:40-43) asserting a false cause — 'no passphrase or recovery phrase is on file beside the library' (StoreProtection.swift:452-457) — over a library where the file is present.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in the real source. StoreKeyEnvelope.load (Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:201-211) throws .unreadable for a file that exists but will not decode, with the doc comment stating exactly why absence must not be inferred; the 13p plan file (line 1481) repeats the design promise verbatim ("a corrupt sidecar THROWS (never reads as 'no passphrase')"). Both consumers then discard it: ProtectionController.swift:159 `(try? gate.loadEnvelope(...)) ?? nil` and AppBootstrap.swift:438. ensuredEnvelope (ProtectionController.swift:162-170) is exactly as quoted — the setAsideEnvelope move fires only on the FOREIGN branch; nil (which now means absent-or-unreadable) falls through to `return (StoreKeyEnvelope(), false)` with a fresh random storeID (StoreKeyEnvelope.init default `UUID().uuidString.lowercased()`). The overwrite road is live and default-on: escrowOn defaults true (StoreProtection.swift:49, and :115 reads the inverted `escrowOff` key so an unset default reads ON); AppBootstrap.finish schedules `protection.reconcile()` on every non-test ready launch (AppBootstrap.swift:351-353); reconcile's escrow arm (ProtectionController.swift:486-493) takes `residentKey ?? guardSeam.loadAuto()` — satisfied under the default Auto mode — then `if !ensured.onDisk { try? gate.saveEnvelope(...) }`, whose live implementation is `try $0.write(at: ...)` → `data.write(to: url, options: .atomic)` (StoreLaunchGate.swift:46, StoreKeyEnvelope.swift:219-221), an unconditional replace of the existing file. `loadEscrow(newStoreID) != key` is then necessarily true, so a second escrow item lands and the old one is orphaned. I looked for the refutations and none holds: no caller anywhere sets aside on unreadable (setAsideEnvelope has exactly one production call site, the foreign branch); no test pins this behavior (every controller/lobby test drives StoreLaunchGate.scripted, whose loadEnvelope closure cannot throw, so the unreadable case is entirely unexercised); nothing in notes/ or KnownIssuesAndTechDebt.md records it as an accepted consequence; and AppBootstrap's own comment ("tolerant of an unreadable sidecar (the lobby's roads re-load and WORD that refusal)") is only deliberate for the FACTS road, not for the controller's write road — and even there it is defeated when both offers read false and StoreLobby.noRoadExists renders ProtectionCopy.deadEnd's false cause over a present file, while the correct .unreadable sentence (StoreProtection.swift:477-484) stays unreachable because no door renders to trigger a re-load. One honest temper on impact: when the file is genuinely corrupt its wraps were already unusable, and restoring the sidecar from a backup folder still heals afterwards (the fingerprint match makes it belong again) — the strict destruction case is a transient read failure (I/O error, permissions, a concurrent replace by a backup/sync tool), where good recovery legs are replaced with no message and `try?` even swallows a failed write. That still violates two rules the file states about itself, silently, at launch, on the credential-insurance layer.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P1.

#### P2. Entering a demanded at-open mode is authorized by a cached `hasPassphraseWrap` projection that two doors invalidate without refreshing, so the mode transition can delete both Keychain items over a wrap-less envelope

`App/Variorum/Shared/ProtectionController.swift:311` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.82

`hasPassphraseWrap` is written ONLY by `refreshEnvelopeFacts()` (:124). Two doors call `ensuredEnvelope(for:)`, which SETS ASIDE a foreign sidecar and writes a fresh WRAP-LESS envelope, and neither refreshes afterwards: `setEscrow(true)` (:354-393, ensuredEnvelope at :360) and `reconcile()`'s escrow arm (refresh at :452, ensuredEnvelope at :488, no re-refresh). Concrete road, all through app doors: (1) a demanded mode over a store whose file is gone/unreadable takes `.openResettingModeToAuto` (AppBootstrap.swift:228-236), which mints a NEW store key — the old `variorum-keys.json` is now FOREIGN (fingerprint mismatch); (2) `init`'s `refreshEnvelopeFacts()` reads that foreign envelope, so `hasPassphraseWrap = true`; (3) `reconcile()` (escrow ON is the Standard default) sets the foreign sidecar aside and writes a fresh envelope with NO passphrase and NO recovery wrap, leaving the stale `true` in place — ProtectionPane.swift:353 now renders "Passphrase — Set" over a library that has none; (4) the user picks "Ask for the passphrase": `setMode` passes the stale guard at :311 and runs `guardSeam.deleteAuto()` / `deleteGated()` (:333-334), keeping `residentKey` so the session still works; (5) next launch routes to `.lobby(demand: .passphrase)` with passphraseOffered=false, recoveryOffered=false, biometryOffered=false → `StoreLobby.noRoadExists`. No copy of that store key exists anywhere (the set-aside `variorum-keys.stale-*.json` wraps the PREVIOUS key). The library is permanently unopenable. `setEscrow(true)` over a foreign sidecar reaches the same end state in two clicks. `applyPreset` reads the same stale field at :400.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced in full. `hasPassphraseWrap` is written only at ProtectionController.swift:97 (init) and :452 (reconcile), both via `refreshEnvelopeFacts()`; grep confirms no other writer and no caller elsewhere in either app. `reconcile()` refreshes at :452 and THEN runs the escrow arm at :467-472, whose `reconcileEscrowOffMain` (:485-500) calls `ensuredEnvelope(for:)` — which at :162-166 sets a non-belonging sidecar aside and returns a fresh empty envelope, saved to disk at :490-493 — with no refresh afterwards. `setEscrow(true)` (:354-372) has the same shape and also never refreshes. `setMode`'s only authorization for the irreversible `deleteAuto()`/`deleteGated()` pair (:333-334) is `guard hasPassphraseWrap` at :311, and `applyPreset` reads the same field at :400. The pane never refreshes either (ProtectionPane.swift has no refresh call), so the stale `true` renders as "Passphrase — Set" at :353 and passes the guard. End state verified: StoreLaunchRoute.resolve returns `.lobby(demand:)` for a present store under a demanded mode, `makeLobby` computes passphraseOffered/recoveryOffered from the (now empty) envelope, and `StoreLobby.noRoadExists` is true — the very state StoreProtection.swift:441-445 asserts is "practically unreachable through the app's own doors." CORRECTIONS to the reviewer's road, which narrow it: (a) `reconcile` runs only from `finish(.ready)` (AppBootstrap.swift:352), so a foreign sidecar can only meet it over a store that OPENED — which in practice means the `.openResettingModeToAuto` fresh mint (AppBootstrap.swift:228-236) or a hand-copied wrong sidecar, not an ordinary restore; (b) the set-aside arm requires `dials.escrowOn == true`, and the Locked-down preset (the usual route into a demanded mode) sets escrowOn FALSE, so the compound needs hand-adjusted dials or the Standard default carried forward. Real and unrecoverable when it fires, but a compound of three preconditions rather than a common road — hence MAJOR, not BLOCKER.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P2.

#### P3. The Mac's automatic re-lock never runs `finalizeWork()`, so open-tail text and a pending cross-block compound are dropped and the pool closes under the late teardown

`App/Variorum/Variorum/VariorumApp.swift:81` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.75

`onWillLock` runs only `session.quitFinalize.finalizeAll()` + `services.stop()`. `quitFinalize` holds one closure per open post (AppSession.swift:183) running `savepointOnLeaving`, which is only `flushExistingAutosave` + `closeAutoCommit` (AppSession.swift:378-384). The OPEN TAIL has no variant, so the AutosaveCoordinator holds nothing for it and neither line can reach it. The quit door runs BOTH halves (VariorumAppDelegate.swift:58-65) because `EditorViewModel.finalizeWork()` is the only thing that awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail through `CrystallizationPlanner` + `ops.newBlock`. `finalizeWork` has exactly three callers — the quit door, `teardown()` (fire-and-forget from `.onDisappear`, EditorView.swift:107), and the seal road — and the lock road reaches none. `AppBootstrap.lock():404-427` then sets `state = .locked(...)` and immediately `await Task.detached { binding.lock() }.value`, closing the pool; the `.onDisappear` teardown fires only on the next render pass and its `runner.run { ops.newBlock(...) }` races that close, throwing `StoreLockedError` at `AppDatabase.currentWriter()` onto a view that no longer exists. Concrete: with `relockOnSleepAndScreenLock` on, type a paragraph at the end of a note (in `one_block` segmentation the whole entry is the open tail) and hit ⌃⌘Q or close the lid inside `tailIdleDebounce = .seconds(2)` — the text is on screen, in no row, and the lobby replaces the view.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end and the asymmetry is exactly as claimed. VariorumApp.swift:81-85 wires `onWillLock` to `quitFinalize.finalizeAll()` + `services.stop()` only; the quit door (VariorumAppDelegate.swift:53-68) additionally awaits `session?.editorRouter.active?.finalizeWork()`. The registry's closure is `savepointOnLeaving` (AppSession.swift:367-384) = `flushExistingAutosave` + `closeAutoCommit` — neither can reach the open tail, which has no variant and therefore nothing in the AutosaveCoordinator. Only `finalizeWork` (EditorViewModel.swift:531-587) awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail via CrystallizationPlanner + `ops.newBlock`. `finalizeWork` is called only from the quit door, `teardown()` (EditorView.swift:107 `.onDisappear { model.teardown() }` — result discarded), and the seal road; `onWillLock` is wired in exactly two places (Mac + phone) and the Mac's is the one without it. AppBootstrap.lock():404-427 then flips `state = .locked` and awaits a detached `binding.lock()`, which nils and closes the writer (StoreBinding.swift:89-102), so the late `.onDisappear` teardown genuinely races the pool close. The phone's twin is the mirror image: mobileWillLock (MobileRelock.swift:90-106) calls `editors.flushAll()` → `MobileEditorViewModel.finish()` (:461-473) which mints the tail — under a comment claiming it mirrors the Mac's closure. One factual nit in the finding: Lock Now is ⌃⌘L (EditorCommands.swift:305-308), not ⌃⌘Q — but ⌃⌘Q is the system screen-lock chord and reaches the same road through the `com.apple.screenIsLocked` observer (ProtectionController.swift:628,654) when relockOnSleepAndScreenLock is on. Severity kept MAJOR: real loss of the paragraph on screen on a deliberate leaving road, no filesystem anomaly required; not BLOCKER because it needs a demanded mode and the ~2 s tailIdleDebounce window.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P3.

#### P10. ProtectionController.setPassphrase writes a stale envelope over a recovery wrap landed during its KDF — the shown twelve words stop opening the library

`App/Variorum/Shared/ProtectionController.swift:177` · **MINOR** · CONFIRMED · data-loss · finder confidence 0.55

`setPassphrase` reads the whole envelope from disk at :180, suspends in the detached Argon2id derivation at :183 (hundreds of ms by construction), then writes the WHOLE file back at :189 with no version/fingerprint check. `generateAndLandRecoveryPhrase` (:258-275) has NO await between its own read (:265) and write (:267), so it completes entirely inside that window. Reachable across two windows over the ONE controller: `ProtectionNoticeBar` is mounted on the MAIN window (VariorumApp.swift:104-106) over `bootstrap.protection`, while the set sheet is presented in the SETTINGS window, and a macOS `.sheet` is window-modal, so the main window's nudge bar stays clickable. Trace: (1) Settings set-sheet, tap Set — reads envelope E0 (no wraps), suspends in the KDF; (2) main-window nudge bar → "take the recovery phrase" (ProtectionPane.swift:565-578 → PhraseOffer.take → generateAndLandRecoveryPhrase) reads E0, writes E1 = E0 + recoveryWrap, and the twelve words are displayed via PhraseOnlySheet for the user to write down; (3) the KDF returns and line 189 writes E2 = E0 + passphraseWrap — E1 is overwritten and the recovery wrap is gone from disk.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified exactly as quoted. ProtectionController.swift:177-190: `var envelope = ensuredEnvelope(for: key).envelope` is read BEFORE `try await Task.detached { ... setPassphraseWrap ... }.value`, then `try saveEnvelope(envelope)` writes the WHOLE envelope back. `saveEnvelope` (:134-137) is a straight `gate.saveEnvelope(...)` — no merge, no version/fingerprint check, no reload. `generateAndLandRecoveryPhrase` (:258-275) reads and writes with zero awaits between, so it completes atomically inside that window and is then clobbered. Reachability verified rather than assumed: VariorumApp.swift:104-106 mounts `ProtectionNoticeBar(controller: bootstrap.protection)` on the MAIN window and :239-243 hands the SAME `bootstrap.protection` to the Settings window's pane, and the pane presents its own set sheet at ProtectionPane.swift:185 — a macOS sheet is window-modal, so the main window's nudge stays clickable. The nudge's phrase button (ProtectionPane.swift:565-578) routes through `PhraseOffer.take` (PassphraseSetModel.swift:262-273) straight into `generateAndLandRecoveryPhrase`, and neither road consults `controller.busy`. Nothing in the file, CLAUDE.md, or notes/ documents a single-writer assumption for the envelope. Two things keep this MINOR and no higher, both of which the finding states honestly: the window is one Argon2id derivation (~hundreds of ms), and it needs a deliberate click in the OTHER window inside it — a same-window nudge cannot do it, because the notice bar hosts both sheets itself and is covered while either is up.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P10.

#### P11. Both production readers of the key sidecar discard `StoreKeyEnvelopeError.unreadable`, so the lobby dead-ends with a false cause and the set-screen then overwrites the recovery wrap

`App/Variorum/Shared/AppBootstrap.swift:438` · **MINOR** · CONFIRMED · crypto · finder confidence 0.85

`StoreKeyEnvelope.load` deliberately throws `.unreadable` for a file that exists but cannot be decoded, and its own doc states why: "reading corruption as absence would let a surface claim 'no passphrase is set' over a library that has one." Both callers do exactly that with `(try? gate.loadEnvelope(url)) ?? nil`. (a) AppBootstrap.swift:239-245 and the re-lock's lock() at :414-420 build LobbyFacts from the nil, so `passphraseOffered`/`recoveryOffered` are false; with `demand == .passphrase` nothing is offered, `StoreLobby.noRoadExists` is true, and the surface renders `ProtectionCopy.deadEnd` — "no passphrase or recovery phrase is on file beside the library" — over a sidecar that holds both. The correct sentence for this exact case already exists at StoreProtection.swift:476-483 and is unreachable at the lobby. (b) ProtectionController.ensuredEnvelope:165-169 returns a BLANK `StoreKeyEnvelope()` on the nil; `setPassphrase`:180-189 wraps the key into that blank and `saveEnvelope` writes it with `options: .atomic` (StoreKeyEnvelope.swift:221), overwriting the file on disk — so the `recovery` blob (her twelve written-down words) and the `storeID` that names the iCloud escrow item are destroyed with no word said. A FOREIGN sidecar is carefully MOVED aside (`setAsideEnvelope`, line 167) precisely so its wraps survive; an UNREADABLE one is obliterated.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified verbatim. StoreKeyEnvelope.load (:201-212) throws `.unreadable` for an existing-but-undecodable file with the exact doc the finding quotes, and BOTH production readers discard it: AppBootstrap's `loadedEnvelope` (:433-439) and ProtectionController's nonisolated `loadEnvelope` (:157-160), both `(try? gate.loadEnvelope(...)) ?? nil`. (a) The lobby facts built from that nil give passphraseOffered=false/recoveryOffered=false; under `.passphrase` demand biometryOffered is false by construction, so `noRoadExists` (StoreLaunchGate.swift:172) is true and StoreLockView.swift:40 renders `deadEnd`, whose passphrase arm says "no passphrase or recovery phrase is on file beside the library" — a false cause over a sidecar that has both. The correct sentence does exist unreachable at ProtectionCopy.message(for:) :476-483. The `loadedEnvelope` doc's justification ("the lobby's roads re-load and WORD that refusal") is true only when a road renders — StoreLaunchGate.envelopeRoad:268 does propagate and word it — so it is a documented ASSUMPTION that fails in exactly this case, not a documented tradeoff. (b) ensuredEnvelope (:162-170) returns a blank `StoreKeyEnvelope()` on the nil (no setAside, because nil never enters the foreign branch), and setPassphrase (:180-189) writes it through `write(at:)`/`.atomic` (StoreKeyEnvelope.swift:216-221) — an atomic rename over a file the app could not read but the directory lets it replace. Worse than the finding says: reconcileEscrowOffMain (:487-493) does the same `try? gate.saveEnvelope` automatically at every reconcile when the escrow dial is ON. The FOREIGN/UNREADABLE asymmetry the finding names is real (setAside is a move, never a delete). One correction: a NEWER-format envelope decodes fine (formatVersion is a plain Codable field; requireCurrentFormat only guards wrap/unwrap), so `.unreadable` means corruption or an IO/permission failure — which is why severity comes down: the destroyed wraps are only recoverable in the transiently-unreadable-but-intact case.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P11.

#### P12. `StoreFilePresence.classify` reports an existing-but-unreadable store as `.absent`, silently downgrading the persisted at-open mode to Auto and authorizing a fresh key mint over an encrypted store

`Sources/VariorumCore/Persistence/StoreKey.swift:244` · **MINOR** · CONFIRMED · correctness · finder confidence 0.75

`classify` has no `fileExists` check: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }`, so a present, ciphertext-filled store that cannot be opened or read (EACCES/EBUSY/EIO; also a zero-length file after a failed copy) answers `.absent`. `routeAndOpen` additionally maps a failed `defaultStoreURL()` to `.absent` (`storeURL.map(StoreFilePresence.classify(at:)) ?? .absent`, AppBootstrap.swift:222-224). Two irreversible things key off that answer: (1) `StoreLaunchRoute.resolve` returns `.openResettingModeToAuto` and `routeAndOpen` PERSISTS the downgrade — `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` (AppBootstrap.swift:233-235) — so a transient I/O error permanently drops the user out of Locked-down; (2) `resolveStoreKey` re-classifies, sees `.absent` with empty custody (the demanded modes deleted both Keychain items) and takes the MINT branch, saving a brand-new key as the Auto item (AppDatabase+Dependency.swift:136-144). The subsequent `AppDatabase.onDisk` then fails to decrypt the real file, and because that failure is not the typed `keyUnavailable` refusal, `failedOutcome` returns `.failed(error, recovery: nil)` (AppBootstrap.swift:278) — a doorless screen despite a wraps-bearing sidecar sitting beside the store. The bogus key is now persisted, so once the I/O condition clears, every later launch repeats the same doorless failure: `custody.load()` returns it, `resolveStoreKey` returns it unconditionally, the open fails again with `keyUnavailable == false`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Code checks out exactly as quoted. StoreKey.swift:243-249: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }` — there is no `fileExists` check, so a present ciphertext store that cannot be opened for reading answers `.absent`. `StoreFilePresence`'s own doc (:225-226) says `.absent` means "No file (or an empty one)" — the unreadable case is undocumented, unlike the deleted-store case, which IS deliberate and documented (StoreLaunchGate.swift:129-138 and AppBootstrap.swift:228-236 both record it as PROVISIONAL). Both consequences trace: (1) `routeAndOpen` persists the downgrade via `gate.saveDials(dials, scope)` at :235; (2) `openStore` re-classifies at AppDatabase+Dependency.swift:98 and `resolveStoreKey` (:123-143) skips the `keyUnavailable` refusal, mints, and `custody.save(minted)` persists the bogus key — after which the subsequent `AppDatabase.onDisk` failure is NOT typed `keyUnavailable`, so `failedOutcome` (AppBootstrap.swift:278) returns `recovery: nil` and the wraps-bearing sidecar beside the store is never offered, permanently, on every later launch. SEVERITY CORRECTED DOWN to MINOR: the trigger requires a store file that is present, non-empty, and unreadable via FileHandle (broken ownership/permissions after a hand restore is the plausible instance) — narrow. Note the sharp edge is the persisted mint, not the mode downgrade: it converts a recoverable state into a doorless one that survives the I/O condition clearing.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P12.

#### P13. StoreFilePresence.classify reports an unreadable store file as `.absent`, disabling the at-open gate and defeating the never-mint-over-ciphertext refusal

`Sources/VariorumCore/Persistence/StoreKey.swift:244` · **MINOR** · CONFIRMED · crypto · finder confidence 0.70

`classify` maps every FileHandle open/read failure (EACCES, EMFILE on fd exhaustion, EIO, an unsatisfied iOS data-protection class) onto `.absent`, which is indistinguishable from "no store here". Two consumers treat `.absent` as authorization. (a) AppBootstrap.swift:222-224 feeds it to `StoreLaunchRoute.resolve`, whose `guard presence != .absent else { return .openResettingModeToAuto }` (StoreLaunchGate.swift:143) makes AppBootstrap.swift:228-235 **persist** `dials.mode = .auto` via `gate.saveDials` — one unreadable moment permanently turns off her Biometric/Passphrase-at-open gate with nothing said. (`storeURL == nil`, i.e. `defaultStoreURL()` throwing, reaches the same `?? .absent` and the same persisted downgrade.) (b) AppDatabase+Dependency.swift:125-145 skips its `presence == .encryptedOrUnknown` refusal, mints a fresh StoreKey and SAVES it into the Keychain before `AppDatabase.onDisk` fails against the real ciphertext with a generic SQLCipher error (`keyUnavailable == false`). Passphrase mode deletes both Keychain items by design (ProtectionController.swift:330-333), so "encrypted store + empty custody" is its normal steady state — precisely where this fires. On the next launch `custody.load()` returns the bogus key at line 128, `presence` is never consulted again, and AppBootstrap.failedOutcome's `guard error.keyUnavailable` (line 275) can never build the sidecar-unlock recovery road: a doorless dead end over a library whose variorum-keys.json is right beside it.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced both consumers in real source (the only two non-test call sites). StoreKey.swift:243-249 does map every FileHandle-open/read failure to `.absent`, and the enum's own doc only claims `.absent` means "No file (or an empty one)". (a) AppBootstrap.swift:220-235 feeds it to StoreLaunchRoute.resolve (StoreLaunchGate.swift:139-143: `guard presence != .absent else { return .openResettingModeToAuto }`) and that case does `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` — a persisted downgrade of the R13p-5 gate with no sentence at the moment it happens. `storeURL == nil` reaches the same `?? .absent`. (b) AppDatabase+Dependency.swift:124-146 is exactly as quoted: `custody.load()` first, then the `presence == .encryptedOrUnknown` refusal (keyUnavailable: true), then mint + `custody.save`. And ProtectionController.setMode (:331-333) does delete BOTH Keychain items under `.passphrase`, so encrypted-store-with-empty-custody is that mode's steady state — the exact state where the mint fires. Once a bogus key is in custody, `custody.load()` short-circuits before presence is consulted again and AppBootstrap.failedOutcome (:275) requires `error.keyUnavailable`, so the sidecar-recovery road can no longer be built: the dead end is real. Nothing in the 13p plan or the code documents the absent/unreadable conflation (grep for 'classify' in the plan file returns nothing). Severity corrected DOWN: every leg is real, but the trigger is a filesystem/IO anomaly (EACCES after an oddly-permissioned restore, fd exhaustion, an iOS pre-first-unlock background launch under completeUntilFirstUserAuthentication), not an ordinary user road — real but narrow.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P13.

#### P15. The raw 256-bit store key is embedded in SQL statement text, and GRDB puts the executed SQL into every error description — a failure renders the key on the store-failure screen and can persist it into UserDefaults

`Sources/VariorumCore/Persistence/AppDatabase.swift:116` · **MINOR** · CONFIRMED · crypto · finder confidence 0.80

Two statements carry the key as a literal: `PRAGMA key = "x'<hex>'"` in `configuration(key:)`'s `prepareDatabase` (AppDatabase.swift:116, run on EVERY pool connection) and `ATTACH DATABASE ? AS encrypted KEY "x'<hex>'"` (StoreEncryptionMigration.swift:100). GRDB throws `DatabaseError(resultCode:message:sql:)` carrying that statement text (GRDB Statement.swift:440) and `DatabaseError.description` appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally (DatabaseError.swift:566-575; `trimmedSQLStatement` only trims whitespace/semicolons), with `errorUserInfo[NSLocalizedDescriptionKey] = description` (:621) so `localizedDescription` carries it too. GRDB's `publicStatementArguments` redaction protects arguments, not the SQL. Trace: a store whose one-time migration hits a throwing ATTACH (SQLITE_CANTOPEN on a full or read-only volume, an unwritable `.encrypting` temp, the attached-db limit) — the `do` block at StoreEncryptionMigration.swift:96-115 has no `catch`, so the DatabaseError escapes to `AppDatabase.openStore`'s generic arm, which does `StoreOpenError(storePath: url.path, reason: String(describing: error))` (AppDatabase+Dependency.swift:108); `StoreFailureView.swift:49` renders that as `Text(error.reason).textSelection(.enabled)` beside a "Reveal in Finder" button (mobile: MobileStoreFailureView.swift:51). Second path: `StoreBackup.integrityCheck` opens the copy with the KEYED artifact configuration and, on failure, returns `"could not be checked: \(error.localizedDescription)"` (StoreBackup.swift:417); that string becomes `BackupRunRecord.Leg.integrity`, is written to UserDefaults by `BackupLog.append`, and is rendered as a sentence at DataSafetyModel.swift:263/:279.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The channel is real and undocumented. Verified: AppDatabase.swift:116 `try db.execute(sql: "PRAGMA key = \"x'\(key.hexEncoded)'\"")` and StoreEncryptionMigration.swift:100 `ATTACH DATABASE ? AS encrypted KEY \"x'\(key.hexEncoded)'\"` are the only two `hexEncoded` uses outside StoreKey itself. In the pinned checkout (.build/checkouts/GRDB.swift), `DatabaseError.description` at DatabaseError.swift:571 appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally, `errorUserInfo[NSLocalizedDescriptionKey] = description` at :620-622, and `Statement` constructs DatabaseError with `sql:` set. The migration's export block (StoreEncryptionMigration.swift:96-115) is a bare `do {}` with NO catch, so an ATTACH failure escapes uncaught to `openStore`'s generic arm, which does `String(describing: error)` into `StoreOpenError.reason` (AppDatabase+Dependency.swift:101-107), rendered as `Text(error.reason).textSelection(.enabled)` at StoreFailureView.swift:49. Nothing in notes/ or the 13p plan records this; StoreKey.swift:58-61's redaction shows the intent runs the other way. SEVERITY CORRECTED DOWN: the leak needs an error thrown BY one of the two key-bearing statements. `PRAGMA key` almost never errors (SQLCipher defers key validation to the first page read, so a wrong-key/corrupt store fails at `PRAGMA journal_mode`/the first SELECT, whose SQL carries no key), which also weakens the StoreBackup.integrityCheck path the finding cites — its realistic failures come from the fallback `PRAGMA integrity_check` read, not the key pragma. The one genuinely traceable road is a throwing ATTACH during the one-time plaintext migration (unwritable temp path, CANTOPEN, attached-db limit) — real, but a once-per-store road on a shrinking population. Worth fixing (bind the key as an argument, or catch-and-sanitize at both sites), at MINOR.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P15.

---

## 17b — Doors that lose or mis-copy her text

**Status: open, unstarted.** 6 items, no pins.

Six independent doors where the traced outcome is her prose destroyed, a wrong take copied, or a
block resurrected from a timeline she abandoned. They share no mechanism — they are grouped because
they share a **consequence class**, and because that class is the one this project refuses by
construction (*"mutation never reaches anything the author has decided to keep"*).

P4 and P14 are the same anti-pattern on the phone: **state cleared, or a result assumed, before the
write is known to have succeeded** — so a refusal eats the thing the refusal was protecting. P7 is
its desktop cousin: the boards' branch / ＋ new take / ⌘T doors copy the STORE past a dirty buffer,
while the Write editor's identical gesture flushes first — so the same gesture means two different
things depending on which surface issued it. P5 violates **I10 at birth** (a live block must have a
live active variant) and copies text the column was not showing. P6 leaves the redo future unclear ed
across a whole-note content replacement.

### Items

#### P4. The comments sheet clears the typed draft before the write is attempted, so a refusal destroys her comment

`App/Variorum/VariorumMobile/Features/Write/MobileCommentsSheetView.swift:105` · **MAJOR** · CONFIRMED · data-loss · finder confidence 0.85

`submitDraft()` reads `draftField.text`, sets `draftField.text = ""` (line 105), then fires `Task { await model.comments.submitDraft(text) }` (line 107). `MobileCommentsController.submitDraft` -> `run { }` handles a throw with `model.report(Self.refusalMessage(error))` only (MobileComments.swift:113-140) — nothing restores the field. The refusal is reachable by construction: `MobileCommentsController.open(blockID:)` (MobileComments.swift:50-57) has no seal check (fire-and-DO), and `Operations.addBlockComment` calls `ensurePlacementUnlocked` before anything else (Sources/VariorumCore/Operations/Operations+Comments.swift:29-31), throwing `.lockedPost` under a sealed note — the controller even ships the sentence for it. Concrete run: open a sealed note, tap ... -> Comments, type a paragraph, tap Submit. The field empties, the store gains nothing, and she reads "This note is locked — unlock it to change comments." with her text gone and no undo. The `editBlockComment` arm additionally nils `editingID` before running (MobileComments.swift:114-115), so a refused edit loses the target too. A 13p store re-lock produces the same loss with a raw `String(describing:)` dump as the sentence.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. MobileCommentsSheetView.submitDraft (lines 101-108) reads `draftField.text`, writes `draftField.text = ""`, then fires `Task { await model.comments.submitDraft(text) }`; `MobileCommentsController.run` (MobileComments.swift:128-140) catches with `model.report(Self.refusalMessage(error))` and nothing anywhere restores the field. The refusal is genuinely reachable: `open(blockID:)` (MobileComments.swift:50-57) guards only that the slot exists, `MobileBlockMenu.menuElements` appends the Comments row unconditionally (MobileBlockMenu.swift:138-140) and `MobileBlockDecor.swift:259` does the same — fire-and-DO, no seal gate — while `Operations.addBlockComment` calls `try ensurePlacementUnlocked(db, blockID:)` before anything else (Operations+Comments.swift:31) and throws `.lockedPost` under a sealed note; the controller even ships the sentence for it ("This note is locked — unlock it to change comments.", MobileComments.swift:152). Nothing in MobileCommentsSheetView gates the draft field or Submit on `isSealed`. So: sealed note → ⋯ → Comments → type → Add empties the field, writes nothing, and prints a refusal, with no undo. The `editingID = nil` before `run` (MobileComments.swift:114-116) loses the edit target on the same road. Severity held at MAJOR: it is unrecoverable text loss on an ordinary gesture over a shipped note state, and the project has ruled this exact class twice (the quick note's Q2 rule, stated at MobileQuickNote.swift:113-116: "no refusal here is ever reached by a road that discarded her text"). The finding's secondary 13p store-re-lock sub-case is weaker than claimed — a lock tears down the whole `.ready` subtree the sheet lives in — but the sealed road alone carries it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P4.

#### P5. promotePicks copies an ARCHIVED pick as a block's ONLY take — I10 violated at birth, and the copied text is not what the column showed

`Sources/VariorumCore/Operations/Operations+Versions.swift:674` · **MAJOR** · CONFIRMED · invariant-violation · finder confidence 0.85

copyPlacements' fan read (:663) has NO status filter, so an archived take is in `fan`; `lensShown = chosenPicks?[block.id].flatMap { fan.first { $0.id == pick } }` (:674) therefore RESOLVES an archived pick, and with `carryFans: false` `toCopy = [shownVariant]` (:683) makes it the copy's only take. `copyFan` preserves status verbatim (`status: take.status`, Operations+Variant.swift:374), and both `chosenCopyID` and `defaultCopyID` (:710-717) land on that one archived copy. Concrete path: on the Takes/Lenses board pick take T for block B into a scratch column (TakesViewModel.swift:853); archive T from the same board (TakesViewModel.swift:1171 — `ensureNotLastActive` permits it whenever B has another active take); scratch picks are never pruned, so the column silently falls through to B's chosen take (resolvedTake, TakesViewModel.swift:487-499); then ⧉ 'Make this a note' → 'New note, only what this column shows' (LensesBoardView.swift:707) → promoteColumn(carryFans:false) → promotePicks (TakesViewModel.swift:955). RESULT: the new note holds a LIVE, PLACED block whose single variant is status='archived' — zero live active variants (I10). The block still renders (Queries.renderPost's `dflt` join deliberately omits the active check, PostRender.swift:155-157) but every keystroke refuses: autosave → editableVariant throws `archivedVariant` (Operations+Variant.swift:317-321). And the text is wrong: the column was displaying B's chosen take, while the copy carries the archived pick's prose — a door labelled 'only what this column shows' produces different words. `divide` on that block then reads activeVariants == 0 and refuses with `fannedBlock` (Operations+Structural.swift:200), naming a fan that is not there. `promoteLens` is immune because Queries.effectiveLensSelection joins `AND v.status = 'active'` (LensQueries.swift:55-59); the sibling door adoptPicksPreservingChosen validates `take.status == .active` explicitly (Operations+Versions.swift:361-365) — promotePicks alone does not.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced every leg in source. (1) Operations+Versions.swift:663-670 fetches the fan with `WHERE block_id = ? AND deleted_at IS NULL` — no status filter, so archived takes are in `fan`; :673-675 `lensShown = chosenPicks?[block.id].flatMap { pick in fan.first { $0.id == pick } }` therefore resolves an archived pick, and :681-684 `toCopy = [shownVariant]` under carryFans:false makes it the sole copied take. (2) copyFan (Operations+Variant.swift:373-379) copies `status: take.status` verbatim, and :709-717 land BOTH chosenCopyID (from sourceChosenID == the pick) and defaultCopyID (block.defaultVariantId not in the copied set ⇒ falls to shownVariant's copy) on that archived copy ⇒ a live, placed block with zero live ACTIVE variants (I10 as the ops layer enforces it — cf. archiveVariant's ensureNotLastActive, Operations+Deletion.swift:43). (3) copyPost (:583-601) performs no pick validation, so nothing upstream filters. (4) The caller path is real and reachable: TakesViewModel.pick (:745-752, scratch case) and adoptMintIntoColumn (:850-854) write scratch picks with no status re-check; archiveTake (:1171) → archiveVariant permits archiving whenever another active take exists; NOTHING prunes column.picks (all 16 `picks` sites checked — only :881 clears them, on save-as-lens); resolvedTake (:487-499) → PaneTextAuthority.resolvedText (:157-165) falls through to the slot's chosen because projection.fans is the live ACTIVE fan (TakesQueries.swift:13-16); promoteColumn's scratch arm (:947-957) passes the raw picks; the carryFans:false door exists (LensesBoardView.swift:707). (5) Consequences confirmed: PostRender.renderPost's `dflt` join deliberately omits the active check (PostRender.swift:155-157 + the doc at :116-120), so the block renders; autosave → editableVariant throws archivedVariant (Operations+Variant.swift:18, 317-321); divide reads activeVariants == 0 and throws fannedBlock (Operations+Structural.swift:192-200). (6) The asymmetry is real: promoteLens goes through effectiveLensSelection, which joins `AND v.status = 'active'` (LensQueries.swift:53-59), and adoptPicksPreservingChosen validates `take.status == .active` (Operations+Versions.swift:363-365); promotePicks alone does not. No test covers archived + carryFans:false (VersionOperationsTests.swift:366 uses a nonexistent id at the default carryFans:true), and I found no note in notes/ or in the code documenting this as an accepted consequence — the promotePicks docstring (:385-387) claims the opposite. ONE overstatement in the finding, which does not refute it: the copy's archived take IS reachable — TakesBoardView.swift:1113-1150 renders the per-block "archived · n" disclosure with an Unarchive button for any block that has a slot, so the note is not unrecoverable; the wrong-prose half and the I10-at-birth half stand.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P5.

#### P6. restoreNoteVersion replaces a note's whole content without clearing the redo future, so a redo injects a block from the abandoned timeline into the restored note

`Sources/VariorumCore/Operations/Operations+NoteVersions.swift:187` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.85

The redo future is cleared ONLY inside UndoStack.register (redoEntries.removeAll() at UndoStack.swift:136); nothing else clears it (removeAll() has no production caller). restoreNoteVersion registers nothing — it self-classifies as "the recovery-door class" — yet it tombstones every live block of the note plus a purge intent each, and copies a fresh family in. Trace: (1) in note N holding A,B run merge(A,B) → A' minted, entry E registered; (2) press ⌥⌘Z → revertStructural tombstones A' at stamp t2 (its placement row cascades to the same stamp) and E moves onto redoEntries; (3) restoreNoteVersion(N, from: V) replaces the note's content and leaves redoEntries alone; (4) press ⇧⌥⌘Z → reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) reads block.deletedAt == t2, finds the container_block row WHERE block_id = ? AND deleted_at = t2, sees container N still live, revives it, then sets block.deletedAt = nil (:420) and flips the cascade victims (:423). A', holding merged text from the state she explicitly replaced, is resurrected into the restored note with no refusal and no message. The divide flavour wedges instead: restoringTexts names A's variant, which step 2 cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the reapply rolls back, and the entry stays on the redo stack forever (its target is purge-intent-fenced out of the tray, so the refusal is unresolvable) — and redo is strictly LIFO, so every entry beneath it is unreachable for the session. deleteContainer is the same root cause with a milder outcome (live unplaced block inside a tombstoned note). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 uses deleteBlock — a REGISTERING act — so it cannot catch this class.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in source. redoEntries is cleared ONLY at UndoStack.swift:136 (inside register) and :276 (undoing past a redo:nil entry); removeAll() at :304 has no production caller (grep over Sources+App finds only test callers). restoreNoteVersion (Operations+NoteVersions.swift:187) registers nothing — its doc self-classifies as "the recovery-door class" at :176 — yet step 2 (:218-234) tombstones every live placement's block and mints a purge intent per block, and step 3 copies a fresh family in. Its only door, VersionActs.restore (App/Variorum/Shared/VersionActs.swift:40-48), adds no stack handling. Merge's registration (Operations+Structural.swift:747-754) passes restoringTexts: [] for redo, so reapplyStructural's untombstoningBlocks loop (:404-424) hits nothing that can refuse: the minted block's placement row still carries the undo's stamp, container N is live and unlocked, so ensureUnlocked passes, block.deletedAt = nil at :420 and flipBlockCascadeTombstones at :423 — the merged block is resurrected into the note whose content was just replaced. The divide flavour's wedge is equally real: its redo carries restoringTexts: [sourcePreImage] (:246-249) on a variant the restore's Delete Now road cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the whole reapplyStructural transaction rolls back, and UndoStack.redo (:296-303) leaves the entry on redoEntries — strictly LIFO, so the session's redo stack is unreachable thereafter, and no user door can void the fencing intent (PoolAndTray.swift:107-109 / Trash.swift:169 hide the target). Not documented as accepted: notes/plans/post-13l-polish-round.md contains no occurrence of "redo" at all, and AppSpec §9 + OverallModel §3 + UndoStack's own header all state the contrary rule ("any new structural act clears the redo future"). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 does use deleteBlock, a registering act, so it cannot cover this class. deleteContainer (Operations+Container.swift:383) is confirmed to register nothing either, the same root with the milder outcome. Severity held at MAJOR: the road is narrow (structural op → undo → version restore → redo) but the outcome is silent wrong prose in a live note, plus a session-permanent redo wedge, against an explicitly canonized contract.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P6.

#### P7. The boards' branch / "＋ new take" / ⌘T doors copy the STORE past a dirty buffer — the Write editor's identical gesture flushes first

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1047` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.90

A live take pane on the Takes board is buffer-authoritative: each keystroke goes to `authority.bufferEdited` + `autosave.record`, and `AutosaveCoordinator`'s debounce is 500 ms (AutosaveCoordinator.swift:95), so the `variant` row lags the screen for up to half a second. ⌘T is bound to `.newTake` (EditorCommands.swift:153) and the board's routed handler hands the LIVE pane straight to the branch door: TakesBoardView.swift:330 `case .branch: guard let pane = model.focusedPane ... await model.branchTakeRevealed(blockID: pane.blockID, from: pane.variantID, ...)` → `branchTakeRevealed` (TakesViewModel.swift:2002) → `branchTake` (:1047) → bare `session.runner.run { ops in try ops.branchVariant(...) }`. No link in that chain flushes. `branchVariant` copies the source's ROW text inside the transaction (Operations+Variant.swift:196, `text: source.workingText`). Concrete sequence: pane shows "…and then she left."; she types " Or did she?" (pending[V] set, unflushed); within 500 ms she presses ⌘T; the minted take is a copy of "…and then she left." without the new sentence; the ring then moves onto the new card and she keeps writing there, so the two takes permanently diverge on text she never chose to drop. This contradicts OverallModel §3 ("Branching a variant INHERITS the current buffer's text") and the app's own flush-first doctrine — `AppSession.runCopying` (AppSession.swift:316) exists for exactly this hazard ("the copying operations read `working_text` ROWS, so a copy taken inside the editor's autosave debounce lacks the last seconds of typing"), and the Write editor's twin gesture `EditorViewModel.mintCaretTake` (EditorViewModel.swift:2363) does `await autosave.flushNow()` before `ops.branchVariant`. Same-class siblings on the same bare `runner.run`: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) — the Lenses diverge-here door; `addWriteColumn` (:625), `replaceColumnWithNewWrite` (:672) and `writeNewTakesEverywhere` (:989), which call `ops.branchAllFans(post:)` and mint a per-block branch from `shown.workingText` (Operations+Versions.swift:474); and `WriteTakesPanel.swift:238`, whose branch button shares the Write editor's coordinator. Every neighbouring board door — `copyAllTakes`, `moveTake`, `mergeSelectedBlocks`, `commitFocusedTake`, `duplicateAsVersion`/`promoteColumn` via `runCopying` — flushes first, so one gesture behaves two ways depending on which surface it is pressed from.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. TakesBoardView.swift:330 `.branch` → `model.branchTakeRevealed(blockID:from:preferredColumnID:)` (TakesViewModel:2002) → `.takes` arm → `branchTake` (:1047) = `session.runner.run { try ops.branchVariant(...) }` with no flush anywhere in the chain; `Operations+Variant.swift:195` returns `text: source.workingText` (the ROW). Panes are genuinely buffer-authoritative and lag the store: `paneEdited` (:567-576) does `authority.bufferEdited` + `autosave.record`, and AutosaveCoordinator.swift:96 defaults `debounce: .milliseconds(500)`. `revealTake` → `focus()` only flushes AFTER the branch has already read the stale row (:530-531), so the source keeps her text and the COPY is what loses it. The correct sibling exists: `EditorViewModel.mintCaretTake` (:2363-2374) awaits `autosave.flushNow()` before `ops.branchVariant`, so the same ⌘T behaves two ways. Not a documented exemption: the 13e E10 sweep table (notes/plans/phase-13e-takes-block-management.md:2843) is explicitly headed "every door that mints a copy from stored text" and lists only duplicateAsVersion/promoteLens/promotePicks/MembershipChip/divergeForBook/poolDrop — no branchVariant door appears, and the `runCopying` doc's stated reason (:2165-2168) is only that non-copy doors shouldn't pay; branch mints a copy. Strong corroboration that the project treats this as a defect, not a tradeoff: the phone's `branchDisplayed` (MobileTakesBrowser.swift:330-350) flushes first with a comment naming the identical mechanism, landed as a Stage-2-ladder MAJOR (mobile-app-plan.md:2803, :2947). Siblings verified live too: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) are bare `runner.run`; `writeNewTakesEverywhere` (:989) calls `ops.branchAllFans(post:)` on the bare runner. Severity stays MAJOR: wrong content in the copy on a common keyboard road; the original's text is not lost (its flush lands), so it is not BLOCKER-class.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P7.

#### P14. The quick note's `try?` folds a read failure into "There's nothing to save yet", orphans a note that WAS created, and lets the clock mint it a second time

`App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift:682` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.70

`adopt` does `let blocks = (try? await session.database.read { try Queries.renderPost(db, containerID: containerID) }) ?? []` and then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { lastError = refusal(.emptyImport); saveState = .typing; return nil }`. The guard's comment argues unreachability from `importPost` alone ("it mints at least one block or throws") — but `try? … ?? []` converts a READ failure into the identical empty result, which that argument does not cover. Finding 1 supplies the reachable failure: `AppBootstrap.lock()` calls `binding.lock()` and closes the pool while this read can be in flight, after `importPost`'s write has already committed. Consequences, each traced: (a) she is shown "There's nothing to save yet." about a note that exists in SQLite; (b) `postID = containerID` on line 693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` passes on her next keystroke and `mintNow` runs `importPost` again — a second note with the same text, repeatably; (c) `variantID` stays nil, so `record(tail:)`'s `guard let variantID` returns and nothing she types afterwards is autosaved anywhere.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The chain is exactly as described. MobileQuickNote.swift:681-691: `let blocks = (try? await session.database.read { … Queries.renderPost … }) ?? []`, then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { … refusal(.emptyImport); saveState = .typing; return nil }` — and the guard's own justification ("Unreachable through `importPost` (it mints at least one block or throws)") argues only about the WRITE, so the `try? … ?? []` road is genuinely uncovered. Consequences verified: `postID = containerID` at :693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` (:623-624) passes and the next keystroke's `handleTextChange` falls into `armMintClock()` (:497-500) → a second `importPost` with the same text; `variantID` stays nil so `record(tail:)`'s `guard let variantID` (:613) drops every later keystroke. Note the deliberate asymmetry the finding correctly implies: the sibling A1-19 arm DOES set `postID` first, so only this arm can double-mint. Reachability is the narrow part, which is why MINOR is right: it needs the pool to close between the committed write and the read — the `AppBootstrap.lock()` race (binding.lock() on a detached task) is the credible cause, while the file-protection cause the file's other comments name is unlikely after first unlock, since the store directory is deliberately `.completeUntilFirstUserAuthentication` (AppBootstrap.swift:491-501).

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P14.

#### P36. A failed re-read in `applyPendingIfClean` discards the deferred projection instead of restoring it, while both sibling guards restore

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:803` · **NIT** · CONFIRMED · error-swallowing · finder confidence 0.60

`applyPendingIfClean` sets `pendingProjection = nil` before spawning the read task; the `guard let fresh = try? await session.database.read(...) else { return }` arm then returns without restoring it, whereas the two guards immediately after both write `pendingProjection = fresh` on their failure paths. If the read throws — the plausible post-13p trigger is a re-lock / Lock Now closing the keyed store while a settle is in flight — the externally-changed projection (a sync-applied conflict variant, a chosen-variant flip from another surface) is discarded and the surface keeps showing pre-change content until some later store write produces a fresh observation delivery.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The code asymmetry is exactly as described and unambiguous. EditorViewModel.swift:795-816: the method sets `pendingProjection = nil` before spawning the read task; the failure arm is `guard let fresh = try? await session.database.read(...) else { return }` — a bare return with no restore — while the two guards immediately below both write `pendingProjection = fresh` before returning (the busy guard and the generation-fence guard, which additionally re-calls `applyPendingIfClean()`). So on a thrown read the deferred marker is dropped and nothing re-arms it; the surface then waits on the next ValueObservation delivery, which only fires on a further store change. Two honest qualifications that hold the severity at NIT rather than higher: the discarded value is a STALE photograph that would have been re-fetched anyway (so restoring it costs nothing but gains only a retry), and the plausible post-13p trigger the finding names — a re-lock closing the keyed store — would very likely also error the observation itself (EditorViewModel.swift:622-624 sets `statusMessage = "Note observation failed"`), which is a louder failure than the lost marker. The Task is unstructured with no cancellation source, so `try?` is swallowing a store error rather than a cancellation. NIT confirmed: a real one-line asymmetry against the surrounding machinery's own never-lose-the-marker rule, with narrow and mostly-moot consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P36.

---

## 17c — The read layer's P1 debt (query-side)

**Status: CLOSED 2026-08-31** — the pre-13u round's Act 4 (this batch also built Act 3, whose
Sherlock corpus was the instrument). All four items **FIXED**, each with a red-on-old pin verified by
reverting the fix and watching the pin go red. Commits `e08762b` (the schema change, on its own) and
`edee416`.

### Dispositions (per item)

Every pin is a **shape** fact — a query plan or a statement count — never a timing, so it cannot pass
or fail with machine load (P48's own lesson, applied here: a pin that cannot fail is a hole in the
mechanism). All pins live in `Tests/VariorumCoreTests/ReadLayerP1Tests.swift`. Numbers are Debug
builds on the author's M3; the corpus is a seeded probe at 2,000 and 20,000 containers (≈12k and
≈122k variants), plus the real seeded Sherlock library where the surface is a note-level one.

| Item | Verdict | Before → after | Pin (red-on-old verified) |
|---|---|---|---|
| **P18** trayTakes scans `variant` | **FIXED** | ordinary 1-block note **0.836 → 4.783 ms** across the corpus growth; after **0.472 → 0.470 ms — FLAT**. (800-block note: 1.116→5.358 before, 1.715→1.741 after.) | `theTrayTakesListingIsDrivenByTheNoteAndNeverScansTheVariantTable` — plan must not contain `SCAN v` and must name `idx_cblock_order`/`idx_block_last_container`. **Red on old:** both assertions fail (`SCAN v`). Plus an equivalence pin, `theRewrittenTrayListingSelectsExactlyWhatTheCoalesceDid` (moved-away block excluded, released original included), which passes on BOTH shapes by design — that is what makes it an equivalence pin. |
| **P19** versionOfNote N+1 in the Trash | **FIXED** | fifteen versions at 20,000 containers **551 → 15.0 ms**; a single lookup **35.9 → 8.0 ms** | `theTrashListingCostsTheSameStatementsHoweverManyVersionsItLists` — statements for a listing with one version must equal those for ten. **Red on old: 6 vs 16.** Plus `theBatchedPeerLookupKeepsTheSingleDoorsAnswer` (live-peer-then-smallest-id ordering preserved; the single-id door now delegates, so the two cannot disagree). |
| **P20** the classifier has no index | **FIXED** (schema `v1_15`, its own commit) | plain note with zero versions **0.374 → 1.791 ms** across the corpus growth; after **0.215 → 0.218 ms — FLAT** | `theVersionClassifierSeeksItsOwnIndexInsteadOfWalkingEveryPost` + `theDeletedWithRoadSeeksTheSameIndex`. **Red on old:** with the index dropped, the plan is `SEARCH v USING INDEX idx_container_kind (kind=?)`. |
| **P21** activeFans one query per block | **FIXED** | 40 blocks: **40 statements → 1**. On the seeded Sherlock corpus (a 212-block story, on disk and encrypted) `takesProjection` **71.0 → 32.3 ms**; the 800-block fan fetch 353 → 237 ms | `theFanFetchIsOneStatementForTheWholeNote` (**red on old: 40**) + `theBatchedFanFetchMatchesThePerBlockShape` (an entry for every block asked about, empty where the fan is; `(fan_position, id)` order). |

**The verifier's temperings were right, and the record says so.** P20's consequence really is
single-digit milliseconds at any corpus she will have this year (its value is that the shape becomes
flat, on the WRITE path, inside `deleteContainer`'s transaction); P21 really is a constant factor and
not a P1 break, and its improvement is smaller than the statement count suggests because what remains
is decoding the same rows. P18 was the sharpest of the four: it was corpus-linear on an ORDINARY
one-block note, which is what made the doc comment's "never the corpus" false rather than optimistic.

**One residual, recorded not fixed:** P19's pass is still LINEAR in the corpus — the peer is reached
through `container_block` BY BLOCK ID, and the only index on that column is the live-rows partial one,
while the lookup is deliberately tombstone-insensitive. Closing it needs an index on
`container_block(block_id)`, a second schema change with its own write-path cost. It has a
`KnownIssuesAndTechDebt.md` row owned by **12 (Hardening)**, beside its P1-tension siblings.

**False doc comments corrected in the same commits** (the sweep named them): `PoolAndTray.swift`'s
"Cost ∝ this note's own fan history … never the corpus" was false and is now true, with the mechanism
written down; `NoteVersions.swift`'s two "never the corpus" claims now say exactly what is and is not
corpus-shaped.

**Verification at close:** core `swift test` **1465/155 green** (baseline 1457/154; +8 pins in one
suite), three consecutive clean runs. Mac suite **1897/321** with ONE failure — the known load-flaky
`EditorWindowSmokeTests.rewriteStrategyLatencies` pin at 52.98 ms against its 50 ms budget —
**adjudicated PRE-EXISTING**: it failed isolated too (51.9–53.8 ms over four runs, load average
12–20 on a 42-day-up box), and the **pre-round baseline commit `626c8c2`, built in a worktree and run
under the same load, measured 52.53 ms** on the same test. Its KnownIssues row gains this covariate.
Tutorial spine green; the iOS target builds.

---

**Original brief (kept as written, so the closing verdicts can be read against what was claimed):**

4 items, no pins.

Deliberately split from 13u1's O(N²) family: those are editor-seam and belong with the rewrite that
touches that seam. **These four are `Queries/` — a different file, a different fix, and no reason to
wait.**

P20 is the one to look at first and the cheapest to fix: the version-history classifier has no index,
so `deleteContainer` walks every post in the corpus **inside its own write transaction**, even for a
note with zero versions — a corpus-scaled hold on the write lock, not merely a slow read. **A local
index is free under §12**: the Postgres mirrors deliberately carry no indexes beyond the PK
(SyncSpec §2), so adding one locally is not a lockstep event and needs no deploy window. It is still a
schema change, so per CLAUDE.md it takes **its own commit** ahead of anything that uses it.

### Items

#### P18. Queries.trayTakes full-scans the `variant` table inside the tray panel's held observation, contradicting its own P1 doc claim

`Sources/VariorumCore/Queries/PoolAndTray.swift:359` · **MAJOR** · CONFIRMED · perf-p1 · finder confidence 0.92

trayTakes starts FROM variant and only reaches the note through a post-join filter, `COALESCE(cb.container_id, b.last_container_id) = :post`, which is not seekable. idx_variant_block is (block_id, status) and cannot serve a query with no block_id; there is no index on variant.deleted_at anywhere in Migrations.swift. Verified plan against the rebuilt real schema: `SCAN v` — a full B-tree scan of the largest table in the store — then per-row seeks into block/container_block, then USE TEMP B-TREE FOR ORDER BY. Measured: 2.31 ms at 12,030 variants, 25.57 ms at 120,830 — exactly linear, and this is the cheapest possible case because the probe has ZERO deleted variants, so every row is rejected on `deleted_at IS NOT NULL` before any join fires. The call site is not a one-shot: TrayPanel.swift:357-377 puts it inside a single `session.database.observe { ... }` held for as long as the note is open, whose region includes `variant`, so every autosave re-runs the scan. Its four siblings in that same snapshot (trayBlocks, archivedBlocks, preservedOriginals, originFamilyClocks) are correctly note-scoped via `b.last_container_id = :post` on idx_block_last_container; trayTakes is the lone one that is not. Post-13p, each pass also decrypts every page of the variant table under SQLCipher.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and measured. The SQL at PoolAndTray.swift:363-380 is quoted accurately, and the plan against the rebuilt real schema is `SCAN v` (then correlated purge_intent seek, then seeks into block / container_block / variant, then USE TEMP B-TREE FOR ORDER BY). I confirmed the index premise exhaustively: `grep -n INDEX Migrations.swift` shows every index in the store, and there is none on variant.deleted_at — idx_variant_block is (block_id, status) and cannot serve a query with no block_id, and COALESCE(cb.container_id, b.last_container_id) = :post is not sargable, so nothing can seek. Timings: 0.58 ms at 24,000 variants -> 9.35 ms at 240,000 — exactly linear. The sibling contrast is accurate: trayBlocks/archivedBlocks/preservedOriginals/trayCounts all drive from `FROM block b ... WHERE b.last_container_id = :post` (PoolAndTray.swift:95/99, 180/183, 258-278) on idx_block_last_container; trayTakes alone starts FROM variant. The hold is real — TrayPanel.swift:375 sits inside the single session.database.observe at :357, started by `.task { await model.start() }` at :800, and the panel lives in the inspector, which can stay open while she types (the existing KnownIssues row says so in as many words). The doc at PoolAndTray.swift:353-355 ("Cost ∝ this note's own fan history ... never the corpus") is therefore false, and the KnownIssues row that owns this pane explicitly asserts the opposite of the defect ("P1's letter intact; the FREQUENCY changed, not the scaling"), so this is NOT a documented, accepted tradeoff — it is a documented denial of it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P18.

#### P19. Queries.versionOfNote is an N+1 in the Trash listing, and each call scans every post in the corpus (96 ms at 20k notes)

`Sources/VariorumCore/Queries/Trash.swift:180` · **MAJOR** · CONFIRMED · perf-p1 · finder confidence 0.90

trash()'s .note arm calls versionOfNote once per born-archived row inside a Swift .map (Trash.swift:180-182). That statement (NoteVersions.swift:292-311) has no seekable driver for the note side, so SQLite's plan — verified with EXPLAIN QUERY PLAN against the real schema rebuilt from Migrations.swift, stats-free exactly as ships (the repo never runs ANALYZE) — is: SEARCH mine USING INDEX idx_cblock_order (container_id=?) / SEARCH n USING INDEX idx_container_kind (kind=?) / SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX / SEARCH theirs USING INDEX idx_cblock_order. `n` is driven before `theirs`, so the loop is (the version's placements x every post in the corpus). Measured on a seeded probe: 7.02 ms at 2,005 containers, 96.36 ms at 20,006 containers — one call. trash() is HELD live: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit: Self.window + 1 where window = 500 (RecoveryView.swift:199), and the observation's region includes `variant` (the .take arm and strandedOriginals' preview join), so it re-fires at autosave rate. Concrete failure: with 20 deleted saved versions in the Trash and a 20k-note corpus, each observation fire costs ~1.9 s of container walking, and every keystroke's autosave triggers one.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. Trash.swift:180-182 does call `versionOfNote` inside the `.note` arm's `.map`, once per row whose selected `born_archived` is 1. I rebuilt the shipping schema from Migrations.swift (verified: no ANALYZE anywhere in Sources/App, so the planner runs stats-free exactly as it ships) and ran EXPLAIN QUERY PLAN on the verbatim statement from NoteVersions.swift:292-311. The plan is exactly as claimed: `SEARCH mine USING INDEX idx_cblock_order (container_id=?)` / `SEARCH n USING INDEX idx_container_kind (kind=?)` / `SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX` / `SEARCH theirs USING INDEX idx_cblock_order` — `n` is driven before `theirs`, so the inner loop really is (the version's placements x every post in the corpus). My own timings on a seeded probe: 3.06 ms at 2,001 containers -> 34.48 ms at 20,001, i.e. linear in corpus (about 1/3 the reviewer's absolute numbers, presumably a different blocks-per-note density, but the same shape and order of magnitude). The hold is real: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit 501, and AppDatabase.observe's own doc (AppDatabase.swift:200-217) confirms table-grained region tracking that re-fires "in the worst case at autosave rate". One correction to the finding's supporting detail, which does not change the verdict: the `.take` arm never runs here — TrashScope.listedKinds (RecoveryActs.swift:466-468) is {.note,.book,.block,.preservedOriginal} — but the `.block` arm's `LEFT JOIN variant dv` puts `variant` in the region anyway, so the autosave-rate claim survives. Not documented as accepted: trash()'s own header concedes only the strandedOriginals walk and asserts it is "not a held per-keystroke one" (it is a held observation), and versionOfNote's doc makes no cost claim at all. Realistic trigger is ordinary, not exotic: versions ride a note's deletion on its exact stamp, so deleting one note with 15 saved moments puts 15 born-archived rows in the window at once.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P19.

#### P20. The version-history classifier has no index, so deleteContainer walks every post in the corpus inside its write transaction — even for a note with zero versions

`Sources/VariorumCore/Queries/NoteVersions.swift:230` · **MINOR** · CONFIRMED · perf-p1 · finder confidence 0.90

versionHistoryPredicate (NoteVersions.swift:146-185) has only two non-subquery terms — `archived_at IS NOT NULL` and `archived_at = created_at` — and neither column is indexed in Migrations.swift. Verified plan for noteVersionIDs against the rebuilt real schema: `SEARCH v USING INDEX idx_container_kind (kind=?)`, i.e. a walk over every post in the corpus, with the correlated EXISTS evaluated for each born-archived row. Operations+Container.swift:387 calls it on the WRITE path, inside `try database.write { db in ... for versionID in try Queries.noteVersionIDs(db, of: id) }`. The EXISTS is correlated on v.id, so it cannot short-circuit: a note with no saved versions pays the full walk. Measured for a PLAIN note with zero versions: 0.15 ms at 2,005 containers -> 4.29 ms at 20,006 (and ~300-350 ms on a cold page cache). restoreContainer:428 pays the same shape through versionHistoryDeletedWith (`WHERE v.deleted_at = :stamp`, also unindexed; 0.11 -> 1.09 ms). Multi-select delete loops the whole operation (NoteDeletion.swift:139-147 `for id in postIDs { try ops.deleteContainer(id) }`), so selecting 50 notes costs 50 corpus walks in 50 serialized write transactions (~215 ms warm at 20k, far worse cold) during which every autosave blocks on the writer. Same root on the read side: noteVersions (held via observeNoteVersions, NoteVersions.swift:330 — 0.32-5.4 ms at 2k -> 11-15 ms at 20k warm, 353 ms cold) and archivedPosts' `NOT (versionHistoryPredicate(.anyLiveNote))` fence (held via observeArchivedPosts — 0.18 -> 5.22 ms).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism confirmed, magnitude corrected down. versionHistoryPredicate (NoteVersions.swift:174-186) really does have only `archived_at IS NOT NULL` and `archived_at = created_at` as non-subquery terms, neither indexed; the plan for noteVersionIDs against the rebuilt schema is `SEARCH v USING INDEX idx_container_kind (kind=?)` with the EXISTS as a correlated subquery, i.e. a walk over every post. The call site is exactly as quoted: Operations+Container.swift:383-387 runs it inside `try database.write`, and restoreContainer:428-431 runs versionHistoryDeletedWith the same way; NoteDeletion loops deleteContainer per selected note. So the shape is real and P1's letter is broken, and both doc comments (NoteVersions.swift:190-192 "never the corpus"; observeNoteVersions "P1: never the corpus") are false as written. What I could not reproduce is the consequence: my seeded probe measures 0.11 ms at 2,001 containers and 1.18 ms at 20,001 for a plain note — the `archived_at = created_at` test rejects almost every row before the EXISTS fires, so the walk is a cheap index scan plus a deferred row read, not the 4.29 ms claimed, and a 50-note multi-select costs ~60 ms warm rather than ~215 ms. The cold-cache figures (~300-350 ms) are unverified and I would not rely on them. Real, traced, and worth fixing (an index on the classifier, or narrowing the driver), but the actual cost at any corpus she will have this year is single-digit milliseconds inside a short write transaction — narrow, not a defect a user hits.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P20.

#### P21. Queries.activeFans issues one SQLite query per block in a Swift loop, on the held takes projection

`Sources/VariorumCore/Queries/TakesQueries.swift:123` · **MINOR** · CONFIRMED · perf-p1 · finder confidence 0.85

activeFans loops the block ids and runs a separate Variant fetch per block. takesProjection (TakesQueries.swift:87) passes every non-gap slot of the post, and takesProjection is the body of observeTakes (TakesQueries.swift:337), a held observation whose region includes `variant` — so it re-fires at autosave rate, issuing one statement per block each time. Measured on an 800-block note against the rebuilt real schema: 7.81 ms for the shipped N-query shape vs 1.96 ms for the equivalent single `block_id IN (...)` statement — ~4x. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. Both shapes are proportional to the note rather than the corpus, so this is a constant factor, not an asymptotic P1 break.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Accurate as written, including the self-correction that it is a constant factor and not a P1 break. TakesQueries.swift:119-133 is a per-block `Variant.filter(...)` fetch in a Swift `for` loop; takesProjection:87 hands it every non-gap slot of the post; observeTakes:333-338 holds takesProjection, and its region includes `variant` (renderPost and activeFans both read it), so it re-fires at autosave rate. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. I reproduced the measurement almost exactly on the seeded corpus: 7.23 ms for the N-query shape vs 1.98 ms for the equivalent single IN-list statement at 800 blocks (the reviewer got 7.81 / 1.96). Two things keep this narrow: cost is proportional to the note, never the corpus, so observeTakes' own doc ("bounded by construction (cost ∝ this post)") is TRUE and no documentation is falsified; and 800 blocks is a book-chapter outlier — an ordinary note of 20-50 blocks pays a few hundred microseconds of difference, off-main. Real, measured, trivially fixable, low consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P21.

---

## 17d — Purge, sync & bridge honesty

**The `Sources/VariorumCore/Sync/` Fable rider binds P8, P9, P28 and P31.**

**Status: open, unstarted.** 5 items, no pins.

The standing rider makes any change inside `Sources/VariorumCore/Sync/` sync-engine surgery and
therefore Fable work in every phase — that is not a cast decision this entry gets to make. **P30 is
`Bridge/`, not `Sync/`**, so the rider does not reach it; it is named here for subject, not for cast.

**P8 is the only finding in the entire sweep the verifier would not confirm by reading**, and it is
the highest-consequence one in this entry: a permanent, unrecoverable pull stall. Its next step is
therefore **not a fix and not a pin — it is a run.** The Phase 5 harness (two in-memory clients
against the in-process fake server) is where it either reproduces or dies, and *reproducing it is the
red-on-old pin*. If it does not reproduce, it is recorded as refuted and closed; the purge design's
own memo (`notes/plans/phase-13j-purge-memo.md` §4f) is the contract to read it against.

P31 and P30 are the honesty half: a permanently stalled cursor currently reports a **clean, successful
round forever**, and the bridge's shelving failure promises a retry in its own comment that the
advanced cursor makes impossible. Both are cases of the system telling her something is fine when it
is not — which in a sync engine is worse than the underlying fault.

### Items

#### P8. A purge expands the family from the local store only, so a peer row above the purging device's cursor is left on the mirror pointing at a container purged everywhere — a permanent, unrecoverable pull stall

`Sources/VariorumCore/Sync/PurgeJanitor.swift:175` · **MAJOR** · PLAUSIBLE · sync-correctness · finder confidence 0.50

PurgeJanitor.sweep() expands a purge family with `PurgeFamily.expand(db, roots: [root])` against the LOCAL store and hands exactly `expansion.orderedRows` to `transport.executePurge`; the server 'deletes EXACTLY the rows it is handed' with no orphan check (10_phase13j_purge.sql, sync_purge_execute). The horizon that gates eligibility is `min(transport.syncHorizon(...), cursor)` (PurgeJanitor.swift:114), and the device's own cursor sits at head-minus-the-A5-visibility-band (`server_written_at <= clock_timestamp() - interval '2 seconds'`, 10_phase13j_purge.sql:443/455) — so rows written on another device in the last ~2s exist on the mirror and are ABOVE this device's cursor when the sweep runs (the sweep is the round's last step, after pull and push). The intent road has no 30-day gate: collectRoots (PurgeJanitor.swift:318-340) makes a live intent eligible on `s.server_seq <= :horizon` alone. Concrete sequence: phone B creates block X inside note N offline; Mac A deletes N and Delete-Now's it; both devices pull the intent (that is what makes it horizon-eligible); B's next round applies N's tombstone — the container cascade tombstones X and its container_block row with N's exact stamp — and then PUSHES X plus its placement, landing above A's cursor if the push commits inside the visibility band; A's sweep in that same window expands N's family from A's store, which has never seen X, and purges only what it knows. The mirror keeps X's container_block row referencing a container that has been physically deleted from the mirror and from every device. No ledger entry names it (sync_purge_execute ledgers only what it was handed), and nothing re-collects it: reconcileLedger (PurgeJanitor.swift:277-291) expands the ledger roots on B and physically removes X locally there too, so no device holds a tombstone for it. A's next pull delivers that placement row; SyncEngine.foreignKeysSatisfiable resolves `container_block.container_id` -> `container` N, which exists neither locally nor in the arriving batch, so it returns false, stopIndex truncates, and the cursor holds forever — N can never arrive. Tombstoned rows get no exemption: the FK walk runs on every row regardless of deleted_at.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every code link checks out and no guard covers the case. (1) Repairs.swift:505-577 `enqueueSuppressedCascadeVictims` explicitly enqueues container_block/block/variant rows on a live→dead container transition applied from a pull — so a peer that has JUST learned the note is dead is REQUIRED by SyncSpec §7 direction (1) to push rows of that dead family, which directly contradicts the memo §2 premise "no peer can re-push them because no peer still believes the thing is live". (2) PurgeJanitor.sweep :138 expands with `PurgeFamily.expand(db, roots:[root])` against the LOCAL store and hands `expansion.orderedRows` to executePurge; PurgeFamily.expandContainer (:104-125) can only see rows this device holds. (3) 10_phase13j_purge.sql sync_purge_execute is exactly as quoted — `delete from %I where owner_id=$2 and %I=$1` per handed item, ledgering only what it was handed, no orphan check; the 'purged' push refusal keys on the row's OWN id, which the purging device never knew. (4) SyncEngine.foreignKeysSatisfiable (:503-515) introspects FKs from the live schema and has NO deleted_at exemption, so an arriving container_block whose container is neither local nor in-batch truncates the batch and holds the cursor — permanently, since the referent is gone from the mirror. (5) reconcileLedger (:277-291) expands the ledger roots and deleteLocal's them on the peer, removing the child LOCALLY only; nothing ever removes it from the mirror, and no device retains a root to re-collect it. The B2 fix and its pin `aReturnersUnpushedChildNeverLandsAsAMirrorOrphan` cover only the never-pushed variant, as the finding says. WHY PLAUSIBLE AND NOT CONFIRMED — one narrowing fact the finding understates: SyncEngine.pull sends `deviceID` only on the first window, where `since` is the PRE-pull committed cursor, so the peer's device_cursor (and hence the horizon) rises only on its NEXT pull — one full round after it pushed the child. By then the child is normally already visible and the purging device's own pull integrates it into the family, closing the hole. The orphan survives only inside the A5 visibility band (10_phase13j_purge.sql:443/455, `server_written_at <= clock_timestamp() - interval '2 seconds'`) or the pull→sweep gap, i.e. a ~2 s cross-device interleaving. That window is genuine, not hypothetical — FakeSyncServer already models it (`visibilityHorizon`, `holdPushes`/`commitHeldPushes` at :109-153, built for the A5 skew), so a deterministic repro is constructible: hold B's push, let A pull + sweep, release. Whether it is reachable in her real two-device use is a timing question I cannot settle by reading. Severity kept MAJOR: the outcome is a permanent one-way inbound jam (silent, given finding 1) recoverable only by re-onboard, and it falsifies a stated safety premise of the bent-S2 design — but no data is lost locally and the trigger is race-gated.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P8.

#### P9. expandContainer's member-block arm is liveness-conditional, so expanding a LIVE container purges the note and its placements while orphaning every block it held

`Sources/VariorumCore/Sync/PurgeFamily.swift:118` · **MINOR** · CONFIRMED · invariant-violation · finder confidence 0.50

PurgeFamily.expandContainer picks up member blocks with `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at` (PurgeFamily.swift:112-118). If the container row is LIVE, c.deleted_at is NULL and the equality is never true, so the expansion returns ZERO blocks — while the rest of expandContainer still takes all of container_block, lens, lens_choice, canvas_layout, reference, post_tag and reading_post for that container. The one call site that can hand it a live container root is the push path's ledger refusal, SyncEngine.swift:157-176, which expands from the pushed row with no liveness precondition: `let family = try PurgeFamily.expand(db, roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)]); try PurgeFamily.deleteLocal(...)`. Outcome on that path: the container row, its placements and its side rows are physically deleted; its blocks and variants stay LIVE, unplaced, and with last_container_id NULLed by deleteLocal's own detachment arm — the same zero-surface state as Finding 1, and permanently unpurgeable afterwards (a live row is never a tombstone root, and joinStrandedOriginals only reaches ancestors of family blocks). PRECONDITION, stated honestly: reconcileLedger normally screens this safely because a peer's executePurge ledgers EVERY family row, so the blocks arrive as roots of their own; reaching the live-container case needs the ledger scan point to have skipped that peer's entries — which the code itself records as possible (PurgeJanitor.swift:117-122, B9) — plus the row being live locally after a Put back. The reportable part is that B9's stated mitigation does not cover it: "those families re-collect through the 30-day road" is false for a LIVE container, which has no tombstone to re-collect.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The SQL claim is exact and I re-read it: PurgeFamily.swift:112-120 selects member blocks `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at`, so a LIVE container root yields zero blocks while lens/lens_choice/canvas_layout/reference/post_tag/reading_post AND every container_block row (collected by container_id, liveness-blind) still enter the family. deleteLocal then removes them; the surviving blocks/variants keep living, their last_container_id NULLed by the detachment arm, unplaced — invisible (the global unplaced listing is debug-only since J6) and unreachable by any later purge (a live row is never a tombstone root; joinStrandedOriginals returns immediately on an empty familyBlocks set). No FK failure catches it, because block→container is the nullable last_container_id that deleteLocal pre-nulls. I verified no call site guards liveness on the engine's `.purged` handler (SyncEngine.swift:169-175) or on reconcileLedger (PurgeJanitor.swift:~285, which filters only on rowExists). The finding's own cited road is weaker than it thinks and it says so honestly — a peer's executePurge ledgers EVERY family row, so the blocks are usually refused 'purged' as their own roots in the same push loop and self-heal. But a MORE reachable road it did not find strengthens it: PurgeJanitor.swift:179-186 re-expands inside the removal's own transaction AFTER executePurge, with no second verdict, and its own comment rules "a restore that raced the await loses to the purge" — a Put back landing in that network window makes the root live, so the note and its placements go while the just-revived blocks stay live and orphaned. familyVerdict's .stale check (PurgeJanitor.swift:441-447) closes the collection-time case but not this one. Contradicts PurgeFamily's own header contract ("purge is never partial"; the FK-closure argument does not cover the nullable pointer) and B9's stated mitigation ("re-collect through the 30-day road") is indeed false for a live row. Severity MINOR is right: deep race/skip preconditions, no crash or corruption, and the prose survives on disk — it just goes invisible.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P9.

#### P28. reapplyStructural is the only revive road that does not void purge intents; a leftover Delete-Now intent later claims the block and strips its 30-day recovery window

`Sources/VariorumCore/Operations/Operations+UndoInverses.swift:404` · **MINOR** · CONFIRMED · data-loss · finder confidence 0.75

revertDeleteBlock, revertDeleteVariant, restoreVariant and restoreContainerRows all call voidPurgeIntents when they flip a tombstone back, with the reason written at the site (13j ladder B, B1). reapplyStructural's untombstoningBlocks loop flips exactly the same block tombstone and does not. Trace: divide a block, type in the minted successor C (so revertStructural's `diverged` test at :300 stamps last_container_id and C lists in the note's tray) → ⌥⌘Z → press Delete Now on C in the tray, which mints a LIVE purge_intent for ('block', C) → ⇧⌥⌘Z, which un-tombstones C while the intent stands (single-device convergence is then saved only by the janitor's own .stale verdict at PurgeJanitor.swift:145-156) → but if she deletes C the ordinary way before the next sweep, the intent is still live and now names a genuinely tombstoned row: PoolAndTray.swift:107-109 fences it out of the tray (`pi.deleted_at IS NULL`), familyVerdict no longer reads .stale, and the janitor physically removes C at the horizon. C never appears in the Trash and never gets the 30-day window the ordinary delete promises.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The asymmetry is exactly as stated. voidPurgeIntents has five callers (Operations+UndoInverses.swift:63 revertDeleteBlock, :87 revertDeleteVariant; Operations+Placement.swift:129 restoreBlock; Operations+Deletion.swift:116 restoreVariant; Operations+Container.swift:468 restoreContainerRows; plus Operations+Reading.swift:156) — every road that flips a tombstone back, each with the 13j ladder B (B1) reason written at the site. reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) performs the identical block.deletedAt = nil + flipBlockCascadeTombstones transition and does not call it. The other two re-applies are safe by delegation (reapplyMintedContainer → restoreContainer, reapplyImportedBlocks → revertDeleteBlock), so this loop is the single hole. The consequence chain checks out: the fence predicates are stamp-aware and a LIVE intent (pi.deleted_at IS NULL) hides the row unconditionally (PoolAndTray.swift:107-109, Trash.swift:169 — whose own comment states the intended rule, "A VOIDED intent from before a re-delete never hides the fresh tombstone's row"), and PurgeJanitor.familyVerdict (:442-449) returns .stale only while the row is LIVE, so an ordinary re-delete before the next sweep flips the verdict to eligible and the janitor removes the bytes with no Trash listing and no Put back. Correctly rated MINOR: the janitor's .stale second net (PurgeJanitor.swift:151-156) closes it on the next sweep, so the hole is a redo→re-delete window of minutes-to-an-hour, and reaching it needs a tray/Trash Delete Now on an undone structural mint.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P28.

#### P30. The bridge's daily-book shelving failure is a one-shot ephemeral note, and its own comment promises a retry the advanced cursor makes impossible

`Sources/VariorumCore/Bridge/BridgeEngine.swift:240` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.85

pullAndLand commits the day agreement AND advances the pull cursor at :220-229, then calls ensureDailyBookMembership at :240-247. When shelving fails (store read failure, bookFinished, bookAtCapacity, wrongKind, refused — :334-357) it returns a note appended to report.landing.notes. That note is the ONLY record, and it is doubly unreliable. (a) It never recurs: the cursor is already past that Fragments row so transport.pull(after:) never serves it again, and even if it did, recordDay wrote the day's hash in the same transaction, so land() returns .skipped at :400-402, outcome.wroteToTheDay is false (:292-299), and ensureDailyBookMembership is never called again. The only other callers of Operations.shelveInDailyJournalBook are ⌘J (BookStructureModel.swift:657) and the phone's Today door — both need the author to open that exact day; nothing sweeps. So the comment's "the next bridge round retries it" is false. (b) It is discarded outright by any failure in the same round's push half: BridgeEngine.run() runs push AFTER pullAndLand (:169-170), push throws on transport.fetchLocalUserID() (:869) or transport.push (:909) — an ordinary network hiccup — and BridgeScheduler.runOneRound only publishes status.issueNotes on the success branch (:105), keeping the previous round's values on a throw (:106-118). Concrete run: her Fragments entry for 2026-09-01 lands into an at-capacity daily journal book; shelving returns the 'note cap' note; the push half then hits a 500 or offline. The entry is live in the Pool, permanently outside the Journal book, and nothing anywhere ever says so. Even on a clean round the note lives exactly one round in a hover tooltip (App/Variorum/Shared/BridgeStatusViews.swift:88) — the same posture the 9b round-2 MAJOR rejected for receipt notes ("the producing event is one-shot, so persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation", :1303-1311), which is why unrescuedBodyNotes (:752) and strandedDeletionDays (:845, :854-856) were made durable and recurring. BridgeDailyBookTests only asserts the note appears in the producing round's report (:193-194, :214-216, :261) — nothing pins persistence, so the gap is invisible to the suite.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in Sources/VariorumCore/Bridge/BridgeEngine.swift and BridgeScheduler.swift. The control flow is exactly as described: the day agreement + cursor advance commit in one write (~:220-229), then ensureDailyBookMembership runs (:240-247) and can only return a String appended to LandingReport.notes. The retry promise at :334-336 ("the next bridge round retries it") is FALSE on the path it annotates: the cursor is past that Fragments row, and even a re-served row hits the echo/replay skip at :400-402 (incomingHash == context.state) whose LandOutcome.wroteToTheDay is false (:292-299), so shelving is not re-attempted. I grep-verified there is no sweep: shelveInDailyJournalBook has exactly three production callers (BookStructureModel.swift:657 ⌘J, MobileTodayDoor.swift:45, and the bridge), none of which sweeps past days. The durability contrast is real and is the project's OWN doctrine, written 40 lines above the shelving code (BridgeEngine.swift:745-752: "the producing receipt was one-shot, so the persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation") — unrescuedBodyNotes re-reads from the store every round; the shelving note does not. Claim (b) also holds: BridgeScheduler.runOneRound assigns status.issueNotes only on the success branch (:105); a push-half throw discards the whole RoundReport including the landing's completed notes, and the catch branch's own comment ("a failed round learned nothing about them") is inaccurate for a round whose landing half succeeded. WHAT I DISCOUNTED, and why the severity drops: (1) no data is at risk — the entry is committed to the store before shelving is even attempted, and its bookless state is durably visible on the Pool surface (AppSpec: "Pool = bookless posts (R29)"); (2) the land-and-speak-on-the-round-note-surface posture is documented and ladder-adjudicated (phase-13c plan, A1 rule 1, naming LandingReport.notes → Status.issueNotes → the status row's "needs attention" as the surface); (3) bookFinished/bookAtCapacity/wrongKind are the author's own deliberate book states, which AppSpec explicitly forbids the bridge to override, and ⌘J speaks the same refusals; (4) "it never recurs" is overstated — any later WRITING landing on that day re-runs shelving and re-emits the note, so the gap is only for days Fragments stops touching. What survives is a real notification-durability gap plus a demonstrably false in-code retry promise — narrow, not user-facing loss.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P30.

#### P31. A permanently stalled pull cursor is reported as a clean, successful sync round forever — PullReport.stalled has no production reader

`Sources/VariorumCore/Sync/SyncScheduler.swift:196` · **MINOR** · CONFIRMED · error-swallowing · finder confidence 0.85

SyncEngine.pull() truncates the batch at the first row whose FK closure is unsatisfiable (the straggler guard). When that is the FIRST row, stopIndex == 0, so `newCursor = since` — the cursor does not move, no row is applied — and pull() RETURNS NORMALLY with `report.stalled = true` (SyncEngine.swift:371-374). SyncScheduler.runOneRound discards the report (`_ = try await engine.pull()`) and then unconditionally executes `status.lastError = nil` / `status.lastErrorIsOffline = false` / `status.lastSuccessAt = date.now`. Concrete outcome: with one permanently unresolvable row in the changefeed (see the purge-orphan finding for one way to create one), every subsequent round integrates ZERO server rows while the status surface reports "last success: just now" indefinitely. Pushes are unaffected, so local writes keep flowing to the mirror and the two stores diverge one-way, silently, under a green light. `grep -rn 'stalled' Sources/ App/` finds no production consumer — only Tests/VariorumCoreTests/SyncPullTests.swift:162,326. PushReport.deferred (rows left enqueued because their referents never arrived) is discarded the same way. The pattern exists and was deliberately applied in the sibling subsystem: BridgeScheduler.swift:104 does `status.stalled = report.landing.stalled`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. SyncEngine.swift:371-374 sets `report.stalled = stopIndex < batch.count` and holds the cursor at `since` when stopIndex == 0. The ONLY two production callers of pull() are SyncScheduler.swift:196 and VaultBootstrap.swift:167, both `_ = try await engine.pull()`; grep over Sources/ + App/ finds no other reader of PullReport at all, and `stalled` appears only in SyncPullTests. runOneRound then executes lastError=nil / lastErrorIsOffline=false / lastSuccessAt=date.now unconditionally, and SyncStatusViews.swift:335 renders that as "Synced <time>". PushReport is discarded the same way, and BridgeScheduler.swift:104 does surface its twin signal, so the pattern is a deliberate one applied next door and not here. TWO MITIGATIONS THE FINDING MISSED, which is why I cut the severity: (a) the field is documented in-code as "the last round that COMPLETED WITHOUT ERROR" — under a stall that is literally true, no exception was thrown; (b) the stall is NOT wholly invisible — DataSafetyModel/SyncSafetyWords.cursorDetail renders "Received everything your account had through change #<cursor>", so a frozen cursor is on a user-facing surface, and that sentence stays honest under a stall (the headline "Everything written on this Mac has reached your account" is about the push half and is also unaffected). The harm therefore needs a PERMANENT poison row, and the permanent-jam class is already an owned KnownIssues row ("Poison-row isolation / park-and-heal", owner 12) whose remedy is to be assessed against soak evidence — soak evidence read from cursors and row counts, not from this in-memory flag, so "unmeasurable by the soak" is overstated. Real, cheap to fix (one line, the BridgeScheduler precedent), narrow in consequence.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P31.

---

## 17e — Correctness & honesty singles

**Status: open, unstarted.** 10 items, no pins.

Ten unrelated defects, each small, each traced. No shared mechanism — this is the catch-all, and it
is the entry most likely to be split when it is actually run.

Worth pulling out of the pile: **P23** (a CRLF file imports as ONE block — `SegmentationRules` splits
on `\n` only) is the kind of thing that will look like data loss to a user importing from Windows or
from an email; **P26** is a genuine liveness race that ends with two editors `isLive` at once, which
is a P3 violation and the exact thing `PaneTextAuthority` exists to make impossible; **P27** and
**P29** are both cases of a *document* — a code comment, a door's own doc — describing behaviour the
code does not have, which is the class that costs the next session the most time.

### Items

#### P23. SegmentationRules splits on "\n" only, so a CRLF file imports as ONE block instead of one block per paragraph

`Sources/VariorumCore/Domain/SegmentationRules.swift:67` · **MAJOR** · CONFIRMED · correctness · finder confidence 0.95

`"\r\n"` is a SINGLE Swift Character and is not equal to Character("\n"), so `text.split(separator: "\n")` finds no separator in CRLF text. VERIFIED by running Swift: `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` == 1; `Character("\r\n").isNewline` == true; `.trimmingCharacters(in: .whitespaces)` leaves it unchanged. Traced path with no normalisation anywhere: ImportModel.readFiles (App/Variorum/Variorum/Features/Import/ImportModel.swift:164-170) does `Data(contentsOf: url)` -> `String(data:encoding:.utf8)` -> Operations.importPost (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `bulkSegments(text, mode:)` -> returns `[wholeFile]` -> `mintSegments` mints ONE block. INPUT: drop a Windows-authored `.md`/`.txt` on the library. OUTPUT: a note whose entire body is one block — no per-paragraph blocks, takes, lineage or reordering, and a document-sized single variant; silent, nothing refuses. Same door serves quick note (13f W5 `undoLabel:`) and mobile capture. The rest of the family disagrees with this file: BoundarySnapping.paragraphBoundaries:280, MarkdownSyntax.spans:183, MarkdownEditing.lineRanges:365 and MarkdownRendering.render:166 all key on `Character.isNewline`, which is TRUE for "\r\n", "\r", U+0085, U+2028, U+2029 — MarkdownRendering.swift:190 even says "a \r\n is one Character and stays one." Only the segmenter uses a literal "\n". No CRLF fixture exists anywhere in the suite (grep over Tests/ and both app test targets).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end and re-measured independently. (1) The Swift fact holds: I ran `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` and got 1, with `Character("\r\n").isNewline == true`. (2) The road is real and unguarded: `ImportModel.readFiles` (App/Variorum/Variorum/Features/Import/ImportModel.swift:157-172) does `Data(contentsOf:)` -> `String(data:encoding:.utf8)` with NO line-ending normalisation, hands the raw text to `Operations.importPost` (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `SegmentationRules.bulkSegments(text, mode:)`. (3) In `.paragraph` mode (the schema seed `('default_segmentation','paragraph')`, resolved by `globalSegmentation` at Operations+Import.swift:88-92) the single un-split 'line' is not blank, so `trimmedPiece` returns the whole file and ONE segment comes back; `mintSegments` (Operations+Import.swift:98-111) mints exactly one block per segment, so the whole document becomes one block/one variant. Nothing refuses, nothing warns. (4) I searched for any normalisation or prior decision: `grep -rn 'CRLF|line ending' notes/` returns exactly ONE hit, notes/plans/phase-13d-refusal-ergonomics-floor.md:3016, and it is about a DIFFERENT function — `seamTrimmedHalves`' `count(where: \.isNewline)` — where it correctly reasons that grapheme clustering makes `\r\n` safe. So the class was reasoned about and this call site was missed; it is NOT an owned tradeoff. (5) The finding's family claim checks out: BoundarySnapping's paragraph/word scanners, MarkdownSyntax, MarkdownEditing and MarkdownRendering all key on `Character.isNewline` (true for `\r\n`); only the segmenter uses a literal `"\n"` Character comparison, which grapheme clustering makes false for CRLF. Severity kept at MAJOR: silent, deterministic, on a shipped user-facing door, and it defeats the block-as-atomic-unit for the entire imported note (no fan/reorder/divide/lineage granularity, one document-sized variant). Held BELOW blocker deliberately — no text is lost or corrupted, the paragraphs still render as content under I4, and recovery is re-import after conversion. Sentence mode degrades less (its scanner keys on `isWhitespace`, which is true for `\r\n`), so paragraph mode — the default — is the exposed one.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P23.

#### P26. MobileLivenessAuthority.takeLiveness grants the pen from a stale continuation — two editors end up isLive at once

`App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift:107` · **MAJOR** · CONFIRMED · concurrency · finder confidence 0.75

`takeLiveness` writes `live = editor` (:112) BEFORE two suspension points (`await editor.autosave.flushNow()` :113, `await editor.refreshTakesFromStore()` :115) and hands the pen over AFTER them (`editor.noteLivenessGranted()` :117), with no check that `live` is still this editor. The caller fires an unstructured, unlatched Task per tab tap (MobileShellView.swift:303 `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }`), so two taps interleave. Trace: (1) tap tab B — Task1 stands down editorA, sets `live = editorB`, suspends inside editorB's flush (a real GRDB write through OperationsRunner); (2) tap tab A before that write returns — Task2's loop calls `editorB.standDown()` (isLive=false, endEditing(true), isEditable=false), sets `live = editorA`, flushes, refreshes, grants A; (3) Task1 resumes and calls `editorB.noteLivenessGranted()`, which sets `isLive = true` and `textView?.isEditable = true` (MobileEditorViewModel.swift:296-301). End state: `live === editorA` while editorB is also isLive and editable.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified line by line. MobileLivenessAuthority.swift:107-118: `takeLiveness` stands down siblings synchronously, sets `live = editor`, then awaits `editor.autosave.flushNow()` (AutosaveCoordinator.swift:142 — a real suspension, `try await runner.run { ops.autosave(...) }` per pending variant) and `editor.refreshTakesFromStore()`, and finally calls `editor.noteLivenessGranted()` with NO re-check that `live === editor`. `@MainActor` does not serialize across suspensions, so this is a textbook check-then-act-across-await. Confirmed the entrant: MobileShellView.swift:296-306 fires an unstructured, unlatched `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }` per tab tap with only `guard tab != target`, so a second tap enters concurrently; MobileWriteView.swift:168 `await router.editors.register(model, tab: tab)` is a second unlatched entrant. noteLivenessGranted (MobileEditorViewModel.swift:296-301, file is at Features/Write/, not Features/Editor/ as cited) and the gate belt (:1200-1205) are exactly as quoted. TWO partial refutations, both stated honestly by the finding's own end state: the hidden stack is `.allowsHitTesting(tab == .shelf/.library)` (MobileShellView.swift:126,138) and standDown already resigned first responder, so the wrongly-granted hidden editor has no keystroke road, and the next tabDidBecomeVisible heals it. BUT I traced a strictly worse ordering of the same defect that the finding did not: if Task1 suspends in `fileOnLeaving()` (a non-empty quick note mints — MobileQuickNote.swift:809) and Task2 runs takeLiveness(A) to completion first, Task1 then resumes into takeLiveness(B), STANDS DOWN A, and grants B — leaving the VISIBLE note uneditable and refusing with 'This note is live in your other tab.' until the user navigates away and back. That is user-visible wrong behavior from the same missing re-check, so MAJOR stands.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P26.

#### P27. The ⌘⇧M merge threshold reads the deliberately-frozen `slots` projection, so a fanned merge silently falls through to the un-carrying instant merge — and the receipt naming the lineage road is suppressed with it

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:277` · **MINOR** · CONFIRMED · invariant-violation · finder confidence 0.85

`applyStructural`'s `.merge` arm decides carry-all vs instant from `model.slots[i].activeVariantCount`, an array `EditorProjectionPolicy` deliberately freezes while the editor is busy. Trace: (1) she is typing ⇒ `autosave.isDirty == true`; (2) a take arrives on block B from the phone or a sync-applied conflict variant, `observeSlots` delivers, `EditorProjectionPolicy.decide(busy: autosave.isDirty || mintInFlight || structuralInFlight, …)` returns `.deferUntilClean` (EditorViewModel.swift:638-663) so `slots` is not updated and B's activeVariantCount stays 1; (3) ⌘⇧M on the A|B seam reads trailingArity == 1 and takes the `else` arm ⇒ `runInstantMerge`; (4) `runInstantMerge` never re-reads the store and computes `otherTakes = mergedAwayTakes([...])` from the SAME stale slots ⇒ 0; (5) `runStructural` flushes successfully, `ops.merge(A,B)` runs — merge accepts fanned blocks by design — and B is released to lineage with its real fan behind it; (6) `speakAboutMergedFans(0)` returns at its `guard otherTakes > 0` so nothing is said. `applyPendingIfClean` cannot rescue it: `runStructural` sets structuralInFlight = true before flushing and that method guards on `!structuralInFlight` (EditorViewModel.swift:795). The false-positive direction IS guarded (`runCarryAllMerge` re-reads via `liveActiveFans` and falls back), and the divide twin guards both directions (`runDuplicatingDivide` reads the store; a stale-unfanned divide is caught downstream because `ops.divide` throws `.fannedBlock`). `ops.merge` throws nothing on a fanned block, so this path has no backstop at all.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified in full, severity corrected down. EditorSurfaceController.swift:276-297: `leadingArity`/`trailingArity` come from `model.slots[...].activeVariantCount`, and the `else` arm calls `runInstantMerge` with no store read. EditorProjectionEngine.swift:148-156 pins the precedence `not-loaded ▸ busy ▸ forced ▸ echo ▸ …`, so `busy` (autosave.isDirty || mintInFlight || structuralInFlight — EditorViewModel.swift:646) wins over the echo arm and `.deferUntilClean` sets `pendingProjection` WITHOUT touching `slots` (EditorViewModel.swift:661-662). `runInstantMerge` (:357-374) reads `mergedAwayTakes` from the same stale slots, so `speakAboutMergedFans` returns at its `guard otherTakes > 0` (:340) and nothing is said. `applyStructural` does not flush before the arity read (the flush happens inside `runStructural`, after the fork). The asymmetry claim is exact: `ops.divide` throws `.fannedBlock` (Operations+Structural.swift:198-202) so a stale-unfanned divide is caught downstream, while `ops.merge` (:659-674) guards only adjacency — no fan check at all. Both sibling roads read truth: `openMergeCeremony` (:1045) and `runSeamMerge` (:1705) call `liveActiveFans`, whose own doc comment (:1748-1753) states "From the store — never `model.slots`, which is deliberately stale while the editor is busy", and `planSeamMerge`'s doc (:1668-1676) says a plan-time projection read "is an enablement hint, never an authorization" and that a fan arriving mid-burst stops the merge (pinned). The ⌘⇧M door alone lacks that authorization read in the false-negative direction; the inline comment at :266-268 documents only the false-POSITIVE fallback. Severity corrected MAJOR→MINOR: reaching it needs an external take to land on one of the two blocks inside the dirty/flight window AND an immediate ⌘⇧M; the outcome is the pre-2026-08-09 shipped default (takes stay on the released sources), fully recoverable via lineage and ⌥⌘Z, with no invariant (I1–I10) violated. Worth noting it is a sibling of a class already owned by 13u1 item 8 (`BlockRangeIndex.wholeBlockDeletion`'s frozen-projection fan fence), at a road that row does not name.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P27.

#### P29. The phone's redo door documents a mechanism the code does not have — reapplyStructural DOES overwrite a buffer edited since the undo, silently

`App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift:225` · **MINOR** · CONFIRMED · drift · finder confidence 0.85

reapplyStructural's restoringTexts loop overwrites working_text with postOpText and carries its own insurance commit for precisely the case the comment says cannot occur. Trace: divide(A) at a cut → ⌥⌘Z restores A's buffer to the full pre-cut text → she types a new sentence into A → ⇧⌥⌘Z → at Operations+UndoInverses.swift:431-437 `variant.workingText != preImage.postOpText` is true, `variant.workingText != preImage.text && isDirty` is true so a quiet auto-commit is inserted, then `variant.workingText = preImage.postOpText` drops her new sentence off the surface with nothing said. The doc comment asserts redo 'discards nothing she typed'; reapplyStructural's own doc two files over states the opposite ('a buffer the author edited since the UNDO is about to be overwritten by the post-op text').

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The comment and the code do contradict each other. MobileUndoDoor.swift:224-226 asserts redo "discards nothing she typed"; reapplyStructural (Operations+UndoInverses.swift:426-438) skips only when workingText already equals postOpText, otherwise takes a quiet auto-commit when the buffer diverged and is dirty (:432-434) and then assigns variant.workingText = preImage.postOpText (:435) — and its own doc at :344-348 says plainly "a buffer the author edited since the UNDO is about to be overwritten by the post-op text." The divide/extract registrations (Operations+Structural.swift:246-249, :153-156) do pass restoringTexts, so the branch is live on the everyday road (undo a divide, keep typing in the rejoined block, redo). Note the substance split: the BEHAVIOUR is not a defect — A12 named undo alone and no pendingRedoWarning exists on either platform, which is deliberate — so what stands is the false door comment, and it is false even in the door family's own vocabulary (the undo road also insures first yet is still called "discarding", per StructuralUndoCopy.discardingUndoQuestion and MobileUndoDoor.discardingUndoDetail's "that writing is set aside"). Held at MINOR rather than NIT: it is not cosmetic — it asserts the opposite of a text-discarding behaviour, the class this codebase has corrected as real findings before (the LR2-1 doc correction inside restoreNoteVersion's own comment). No behaviour change is owed; the comment is.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P29.

#### P32. Scratch-column picks ARE persisted to UserDefaults, so the dangling-pick notice is scoped out of them on a false premise

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1196` · **MINOR** · CONFIRMED · spec-conflict · finder confidence 0.90

`danglingPick` restricts the J5 archived-pick notice ('say loudly if that take was archived and this is a fallback WITH a button for quick restore') to lens columns, justifying the exclusion with 'a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session'. That premise is false: `TakesColumn.picks` is a stored `Codable` property (TakesModels.swift:33), `TakesViewMemory` wraps `columns` and JSON-encodes them into UserDefaults (TakesModels.swift:59-73), and every scratch pick write calls `saveMemory()` (TakesViewModel.swift:852-854 → :683). Path: pick take T in a scratch column → archive T (TakesViewModel.swift:1171) → quit → relaunch. The column reloads from UserDefaults still naming T; `resolvedTake` (TakesViewModel.swift:487-499) silently falls through to the block's chosen take; `danglingPick` returns nil, so no notice and no Restore button ever render — permanently, not for one session. The model's own docstring contradicts the comment: 'A view-local profile: sparse picks over chosen, persisted only via VIEW MEMORY' (TakesModels.swift:21-23). This is also what makes the promotePicks defect above silent and long-lived rather than a same-minute slip.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The comment's factual premise is false, verified directly. TakesModels.swift:28-34: `struct TakesColumn: Identifiable, Equatable, Codable` with `var picks: [String: String] = [:]`; TakesViewMemory (:58-73) wraps `columns` and JSON-encodes them into UserDefaults under `takesViewMemory.<postID>`; TakesViewModel.saveMemory (:683-686) writes it, the init (:49-52) reads it back, and every scratch pick write calls saveMemory (:751-752, :850-854). So a scratch pick DOES survive a relaunch, contradicting TakesViewModel.swift:1196-1198 ("a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session") — the model's own docstring at TakesModels.swift:21-23 says "persisted only via VIEW MEMORY". Consequence traced: nothing prunes picks on archive/delete (checked every `picks` site; applyProjection at :433-447 prunes only dead-lens columns and the merge selection), resolvedTake falls through silently (:487-499), and danglingPick returns nil for non-lens columns (:1199-1204) — the notice is rendered only at LensesBoardView.swift:586, so a scratch column shows an unpicked take with nothing saying so, indefinitely. Two corrections to the finding's framing, neither refuting it: (a) the 13j J5 ruling as recorded in the master plan is scoped to a SAVED LENS's pick ("when a saved lens's pick dangles at an archived/deleted take (the core's read-time fallback, `effectiveLensSelection`)"), so scoping the notice to lens columns is not itself a spec violation — what is wrong is the REASON given for it; (b) the surviving defect is therefore a false code comment plus a real but unruled UX gap. MINOR is the right weight; it is not cosmetic, because the same persisted stale pick is the input to the promotePicks defect above.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P32.

#### P33. The Mac's ⌥⌘Z has no in-flight guard, so the A12 destructive-undo confirm can describe a different entry than the one actually undone

`App/Variorum/Variorum/Registry/ShellActions.swift:111` · **MINOR** · CONFIRMED · concurrency · finder confidence 0.70

structuralUndo spawns a Task with no re-entrancy latch and reads the stack twice across two separate runner submissions: pendingUndoWarning (which reads entries.last) and then undo (which reads entries.last again). Two ⌥⌘Z presses landing inside the runner round-trip queue as T1.warn, T2.warn, T1.undo, T2.undo — both warnings are computed against entry E, but T2 undoes E-1. If E is not in the insurance class and E-1 IS, T2 shows no confirm and the discarding undo runs anyway; if the reverse, she is asked about a discard that is not happening. The phone's twin door guards this exactly (MobileUndoDoor.beginUndo: `guard !inFlight else { model.report(Self.anotherIsLanding); return }`), so the Mac is also the drifted copy of a shared rule.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Read both doors. ShellActions.structuralUndo (App/Variorum/Variorum/Registry/ShellActions.swift:111-137) spawns Task { @MainActor } with no latch and makes two separate awaited runner submissions — pendingUndoWarning then undo — each of which reads entries.last independently (UndoStack.swift:250, :266). MobileUndoDoor.beginUndo (:144-149) guards the identical sequence with `guard !inFlight` and its comment gives this exact reason ("a second press inside the first's suspension would pop a second entry she never asked for"), and confirmPendingUndo re-takes the latch at :181 — so the Mac is the drifted copy of a rule the phone states. The only Mac gate is stack-depth enablement (EditorCommands.swift:331 `.disabled(session?.undoMenuState.topLabel == nil)` and CapabilityRegistry.swift:924 `ctx.undoAvailable`), neither of which changes during the flight. The reachable shape is the no-warning one (E silent, E-1 in the insurance class): both tasks compute nil warnings against E, no modal blocks the MainActor, and the second undo discards E-1's buffer without the A12 confirm. The reverse shape self-limits because confirmDiscardingUndo runs a modal NSAlert. MINOR is right — revertStructural's own insurance commit (:284) still rides inside the undo transaction, so the cost is the ruling being skipped, not the bytes.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P33.

#### P34. BoundarySnapping.settle overrides a deliberate EXACT cut placement when a sentence end sits exactly settlePull units earlier, contradicting its own documented contract

`Sources/VariorumCore/Domain/BoundarySnapping.swift:147` · **NIT** · CONFIRMED · spec-conflict · finder confidence 0.95

`effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, and the comparator breaks an effective-distance tie toward the EARLIER position. A strong boundary exactly `settlePull` (=2) units before an exact placement therefore also scores 0 and wins the tie. VERIFIED by running the verbatim function: text "Yes. I went home." has word boundaries [0,5,7,12,17] and strong (sentence) boundaries [0,5,17]; `settle(7, in: text, among: [5,7,12])` returns 5 — 7 is an exact word edge and loses. Second sample "Hi. A word here.": `settle(6)` returns 4. Reachable whenever a one-letter word ("I", "A", "O") follows a sentence end, which is constant in English prose. INPUT: the author drags the divide cut to sit exactly before "went". StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) — the ONE snapper for plain divide, the W ceremony's per-take cuts, CutPropagation's seeding and extract's span edges — moves it two units left. OUTPUT: the divide yields "Yes." + "I went home." where she placed "Yes. I" + "went home.", silently. The suite's own comment at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-144 asserts "Cut 9 is exact: the deliberate placement always wins", but its fixture's strong/plain gap is 4, so effectiveDistance(5)=2 and the exact cut wins for a reason that evaporates at gap <= 2 — no test stands at the boundary the invariant lives on.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by COMPILING AND RUNNING the real BoundarySnapping.swift (not a replica): for "Yes. I went home." the scanners give word boundaries [0,5,7,12,17] and strong (sentence) [0,5,17], and `settle(7, among: [5,7,12])` returns 5 — the exact word edge at 7 loses. Second sample "Hi. A word here.": `settle(6, among: [4,6,11])` returns 4. Mechanism confirmed at BoundarySnapping.swift:145-152 — `effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, so a strong boundary exactly 2 units earlier also scores 0 and takes the tie via `da == db ? a < b`. Production-reachable: StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) is the only snapper for divideAtCursor, the W ceremony's per-take cuts and CutPropagation, and it passes the raw cut with the full interior word set. The test-comment claim at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-146 is also as described — its fixture's strong/plain gap is 4, so the exact cut wins there for a reason that evaporates at gap <= 2, and no test stands at the boundary. SEVERITY CORRECTED DOWN to NIT, and this is the part the finding over-reads: the pull is the deliberate S4-22 gentle-settle feature, and the tie-to-earlier rule is stated explicitly in the SAME doc comment (line 138-139) and exercised deliberately by the neighbouring test's cut-8 case. What is actually wrong is the absolutist parenthetical at line 130-131 plus a missing boundary pin; the behavioural consequence is a 2-unit shift confined to the one-character-word-after-a-sentence-end configuration (". I ", ". A "), where relocating the cut to the sentence end is arguably the settle doing its job. Not a user-facing correctness defect of the kind MINOR implies.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P34.

#### P35. `shelf_pins` never self-heals and a deleted book's pin can never be removed, unlike its self-healing sibling `starred` in the same file

`Sources/VariorumCore/Operations/Operations+Appearance.swift:117` · **NIT** · CONFIRMED · drift · finder confidence 0.90

setShelfPinned's public door runs `_ = try liveReading(db, readingID)` first, so once a pinned book is deleted every unpin attempt throws readingNotFound; the internal writer (Operations+Appearance.swift:129-141) only appends or removes the single id it is handed and never prunes; Queries.shelfPins (AppearanceQueries.swift:70-75) returns the raw decoded array with no liveness filter; and the only other writers of the key (insertDailyJournalBook, ensureQuicknotesBook) pin, never unpin. So: pin book R, delete R — R's id is stuck in the stored JSON permanently, and because `setting` is a synced table the growing array is pushed on every subsequent pin change. No wrong render results (ShelfViewModel.ordered orders live `bookshelf` rows by pin order, so dead ids match nothing), which is why this is a NIT.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and it holds exactly as written. Operations+Appearance.swift:117-122 — the public setShelfPinned runs `_ = try liveReading(db, readingID)` first, and Operations.swift:85-90 shows liveReading throws readingNotFound for any row with deletedAt != nil, so once a pinned book is deleted every unpin attempt throws. The internal writer (129-141) only appends/removes the one id handed to it and never prunes. Queries.shelfPins (AppearanceQueries.swift:70-75) decodes the raw array with no liveness filter ('pins are presentation, never truth' — fail-open on malformed JSON only). I grepped every writer of the key: only setShelfPinned itself plus insertDailyJournalBook (Operations+Container.swift:228) and the quicknote book ensure (Operations+Quicknote.swift:121), both of which PIN — no path unpins on delete, and deleteReading is not among the callers. The contrast with `starred` is exactly as quoted (Operations+Appearance.swift:164-167, 'EVERY WRITE SELF-HEALS… live targets only'). NIT is the right rating and the finding says so honestly: ShelfViewModel.ordered (lines 81-96) walks pins and keeps only ids matching a live `bookshelf` row, and the mobile shelf reads the same way, so a dead id renders nothing. Corroborating evidence the class is already known but unfixed at the op: MobileTutorialSeeder.swift:179 unpins doomed books BEFORE deleting them, and notes/plans/mobile-parity-round.md:2321 pins that workaround with 'Cleanup unpins doomed books so shelf_pins never accrues dead ids across restores' — a caller-side workaround for exactly this hole, which is the drift the finding names rather than a documented acceptance of it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P35.

#### P37. The tray's ARCHIVED listing is silently truncated at 500 while its two sibling listings render truncation markers

`App/Variorum/Variorum/Features/Tray/TrayPanel.swift:400` · **NIT** · CONFIRMED · drift · finder confidence 0.85

`TrayViewModel.start` fetches all three listings with the standing probe row (`limit: Self.window + 1`, window = 500 at :224). `adopt` then flags two of them and not the third: `deletedTruncated = snapshot.deleted.count > Self.window` (:398) and `(takes, takesTruncated) = TrashListing.windowed(snapshot.takes, window: Self.window)` (:402) both survive into the view as `truncation("deleted")` at :777 and :818 — but `archived = Array(snapshot.archived.prefix(Self.window))` (:400) discards the probe row and everything past it with no flag and no marker anywhere in the view. A note holding more than 500 archived blocks therefore shows exactly 500 with nothing saying more exist, on a recovery surface whose entire job is to audit what a note has set aside. The probe row is fetched and thrown away, which is what marks this as an omission rather than a decision.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified in TrayPanel.swift. All four arms fetch with the probe row (`limit: Self.window + 1` at :363, :365, :367, :377; window = 500 at :224). `adopt` (:396-403) sets `deletedTruncated = snapshot.deleted.count > Self.window` and `(takes, takesTruncated) = TrashListing.windowed(...)`, but `archived = Array(snapshot.archived.prefix(Self.window))` with no flag — the probe row is fetched and discarded. `grep -n 'truncation('` yields only :777 (deleted) and :818 (takes) plus the builder at :872; the ARCHIVED section (:724-739) renders `ForEach(model.archived)` and an empty-state line, nothing more. No note in the repo records the omission as deliberate (the only nearby record, the A6 ladder comment at :359-362, is about bounding both listings in SQL, which was done). So it is a real drift from the standing rule quoted in KnownIssuesAndTechDebt.md's "Bounded view windows show markers, not more". NIT is correct: 500 archived blocks in one note is remote, and nothing is lost — only unlisted.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P37.

#### P38. StoreBackup.run has no single-flight latch — two forced runs in the same second write and prune the same backup file

`App/Variorum/Shared/StoreBackup.swift:143` · **MINOR** · CONFIRMED · concurrency · finder confidence 0.70

`run(force:)` spawns `Task.detached { performRun(...) }` with no in-flight guard, and two independent trigger sources reach it: the hourly `start()` loop → `backupIfDue()` (:112-120), which is outside any UI state, and the UI, whose `busy` latch does not cover every door — `DataSafetyModel.setInsurance` calls `backup.backUpNow()` with no `busy` guard (DataSafetyModel.swift:125-136) and its Toggle is not `.disabled(model.busy)` (DataSafetyPane.swift:159-160), unlike the Back Up Now button (:87). The destination filename stamp is second-granular (`"yyyy-MM-dd-HHmmss"`, :478), so two parallel runs in the same second compute the SAME path. Each then (a) opens its own DatabaseQueue at that path and runs sqlite3_backup into it (AppDatabase.swift:189-196); (b) runs `integrityCheck`, which executes `PRAGMA journal_mode = DELETE` and deletes `url + "-wal"` / `url + "-shm"` (:401-406) while the other run may still be writing that file; (c) runs `prune(directory:keep:)` (:440, :446-452) — both list, both compute the same doomed set, both `removeItem(at:)`, and the loser throws NSCocoaErrorDomain 4 out of `performBackupIfDue`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every quoted fact checks out. StoreBackup.swift:143-162: `run(force:)` captures `let stamp = now()` and spawns a bare `Task.detached { performRun(...) }` with no in-flight guard anywhere in the file (grepped for latch/in-flight/reentrancy language — none). The filename is second-granular (`"yyyy-MM-dd-HHmmss"`, :477-478) and is built from that entry-time stamp (:437-438), so two runs entering in the same UTC second compute the SAME path, then each opens its own `DatabaseQueue` at it and runs `writer.backup(to:)` (Sources/VariorumCore/Persistence/AppDatabase.swift:189-196). `prune` (:446-452) is unguarded oldest-first `removeItem`, and `keep = 14` (:47), so on any install older than two weeks both runs compute the same doomed set and the loser's `removeItem` throws out of `performBackupIfDue` into the `catch` at :516-ish, setting `primary.outcome = .failed` and `lastError` (:159-161) for a run whose snapshot succeeded. The un-latched door is real: DataSafetyModel.swift:125-136 `setInsurance` calls `backup.backUpNow()` with neither `guard !busy` nor `busy = true` (contrast :219, :239, :249), and its Toggle (DataSafetyPane.swift:158-160) carries only `.disabled(model.destination == .unset && ...)`, so 'Back Up Now' (:87 `.disabled(model.busy)`) stays live while the toggle's forced run is in flight. `integrityCheck`'s sidecar deletion (:395-402) is as described. MINOR is right: it needs two forced acts inside one second, and the worst outcomes are a false 'failed' receipt on the freshness face and a possibly-bad concurrent snapshot beside good ones.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P38.

---

## 17f — Dead code, canon corrections & test pins that cannot fail

**Status: CLOSED 2026-08-31 — the pre-13u round's Act 5 (Opus implementer,
commits `8bb0185…6ee0451` on `main`).** Eight items **FIXED**, one
**DISMISSED AS HOLLOW**. The batch record — counts, the drills' numbers, the
paired latency adjudication — is the **ACT 5 BATCH RECORD** section of
`notes/plans/pre-13u-round.md`.

### Dispositions (per item)

| item | verdict | evidence class | notes |
|---|---|---|---|
| **P42** | **FIXED** | hoist (architectural): grep 5 → 0 duplications; 4 new pins | `CrystallizationPlanner.kindForTailEdit(mode:bulkPending:)` + `kindForDurabilityMint(mode:)` in `Shared/`, called from all five sites (Mac ×3, phone ×2). Both switch EXHAUSTIVELY, so a fourth segmentation mode is a build failure at the one place that decides. No behaviour change; the pins cover both occasions across every mode **and the one way they deliberately differ** (outside `one_block`: tail edit crystallizes as you type, durability mint takes the whole tail with the trailing run preserved). |
| **P43** | **FIXED** | grep-verified dead code (the finding's own standard) | `fanAction` + `enum FanAction` + `loadFan`'s `Queries.blockFan` read + `FanPanelState.variants`/`.chosenVariantID` removed; `openFan` is synchronous now. `FanPanelState` KEPT (the sheet's `item:` binding — the verifier's correction). `refusalsSurfaceAsMessages` **re-pointed onto a live door** (⌘⇧A `archiveCaretTake` on a last active take — I10 refuses, the status line must say so), and the two tests reading `.variants` now read arity from the STORE. |
| **P44** | **FIXED (documented)** | traced mechanism + documented decision | `removeAll()` is NOT dead — it has four test call sites; what was missing was the statement that it has **no production caller and deliberately none** (no app road clears undo history), which it now carries at the declaration. The ceiling-less retention is recorded at `entries` with its bound (per act ∝ the edit ⇒ P1's letter holds; session-scoped, never persisted). **No cap invented** — a retention ceiling is a product call (how far back can she undo?) and a stack that silently forgets is the surprise the pointer religion exists to avoid. **Architect note, not a KnownIssues row:** if a ceiling is ever wanted it is the author's, and nothing measured says it is needed. |
| **P45** | **FIXED** | grep-verified dead code + doc correction | `BoundarySnapping.snap` had ZERO production callers on either platform, kept green by its own four tests, while `divide`'s op doc named it as the boundary contract — a rule no door enforces (the shipping one is `settle`, and the two disagree within `settlePull`). Function + its four tests removed; `Operations+Structural`'s divide doc and `StructuralGesturePlanner`'s header now name `settle`. The UTF-16-across-emoji pin survives, re-pointed at `settle` (same answer, 16). |
| **P46** | **FIXED** | canon aligned to an already-ruled value | AppSpec §7's seed comment **and** §9's `idleAutoCommit` entry both corrected 24 → 2, each citing 13j's J11 savepoint-cadence ruling and `v1_13_savepoint_backstop`. The verifier's widening (TWO stale places, not one) was the correct read. Nothing else in canon touched. |
| **P47** | **FIXED** | **red-on-old drilled**, both platforms | New `VariorumTests/ProtectionSurfaceRenderTests` (4 pins) + `VariorumMobileTests/MobileProtectionSurfaceTests` (3 pins). **Drill:** deleting `Text(ProtectionCopy.openAppIsReadable)` from the pane and the dead-end `Text` from each lobby fails 3 of 4 Mac pins and 2 of 3 phone pins; the roads-exist complement correctly still passes in both. **Two roads measured and rejected first, recorded in the file** so nobody repeats them: the hosted view's accessibility tree is EMPTY (zero subviews, zero a11y children) and `dataWithPDF` captures nothing (layer-backed). Reflection over the real `body` works, and an untaken `_ConditionalContent` branch is verifiably absent — which is what makes it a composition pin rather than a source grep. |
| **P48** | **FIXED** | **red-on-old drilled** | Budget DERIVED (2 ms → 1 ms: above the cheapest measured large median, 0.32–0.40 ms, below the dearest, ~1.27 ms, so at least one pin is always ratio-bound); every run prints the ratio AND which term bound; the failure message names it; the five query pins renamed flat-**or-under-budget**; the docstring stops claiming "ratios are the assertion". **Drill:** a synthetic 4.38× library-page regression PASSES under the old floor (logged "bound by BUDGET 2.0ms") and FAILS under the new one. See the batch record for what binds per benchmark. |
| **P49** | **FIXED** | **red-on-old drilled**; ZERO `Sync/` edits | New `TriggerCoverageTests` (3 pins) **reads the registry** rather than re-listing it: for all 19 registered tables, both outbox triggers exist, each enqueues its own PK, each writes `sync_outbox`, each carries the `_sync_applying` echo suppression — plus the reverse direction (no outbox trigger for an unregistered table) and the cascade set as an exact named list. **Drill:** skipping one table's trigger pair fires the pin naming the table and the consequence ("its rows would never leave this device and nothing anywhere would say so"). |
| **P50** | **DISMISSED AS HOLLOW** | measurement | The premise — `lock()` closes the last connection, so the WAL is checkpointed away before the scan — is FALSE on this tree. Probed: the WAL measures **1,100,072 / 1,153,632 bytes before `lock()` and the identical byte counts after**, frames intact, so the scan has always read real WAL content. Not fixed. What WAS real is the silent skip (`if let … try?`), so the read is now hard and the frames asserted present: if a future change ever does checkpoint the WAL away here, it says so instead of quietly becoming the dead belt the finding described. |

*(The original 9-item briefs below are kept verbatim as the entry's record —
the finder claims, the verifier traces, and the provenance note.)*

**Status when written: open, unstarted.** 9 items, no pins.

The cheapest entry, and the one with the best ratio of effort to future time saved.

**The four test findings (P47–P50) matter more than their severity suggests.** This project's entire
review doctrine rests on the red-on-old pin: a finding is not fixed until a test fails on the pre-fix
code. A pin that *cannot* fail is therefore not a weak test — it is a hole in the mechanism that every
future review depends on. P48 is the sharpest instance: five of six P1 benchmarks are gated by an
absolute 2 ms floor rather than the flatness ratio their own names claim, so they would not go red if
P1 were violated — which is what they exist to catch, and which several findings in this very sweep
allege is already happening.

**P46 is a canon correction**, not code: AppSpec §7's seed comment still says `idle_commit_hours = 24`
where the shipped seed is 2 (the 13j savepoint-cadence ruling dropped it). Correcting canon costs
minutes and prevents a future session from designing against a number that has not been true since
August.

### Items

#### P42. The segmentation-mode → crystallization-kind rule is written out five times across the two platforms with nothing pinning them together

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1343` · **NIT** · CONFIRMED · drift · finder confidence 0.80

`CrystallizationPlanner` owns the planning but not the kind selection, so the mapping is duplicated at EditorViewModel.swift:559-560 (`finalizeWork`), :1295 (`idleMintTail`), :1343-1344 (`crystallizeIfNeeded`), and MobileEditorViewModel.swift:1619 and :1662-1663. All five are byte-identical today. A rule change (a new segmentation mode, or a ruling that the idle mint behaves differently under `one_block`) landing in `crystallizeIfNeeded`'s default arm leaves the teardown and idle-mint sites — and both phone sites — on the old rule, and the platforms crystallize differently with nothing announcing it.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> All five sites verified verbatim: EditorViewModel.swift:559-560 (`mode == .oneBlock ? .oneBlock : .idle(.paragraph)` in the teardown mint), :1295 (`crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))` in the idle-mint tick), :1342-1344 (`forcedKind ?? (bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing))`), and the phone's byte-identical twins at MobileEditorViewModel.swift:1619 and :1661-1663. `CrystallizationPlanner` owns the planning; the kind SELECTION is duplicated. Byte-identical today, so there is no wrong behavior to point at — this is a genuine drift risk in exactly the class KnownIssues tracks ("Mac app-local brains are forked against mobile siblings") and is absent from that row's eight-item enumeration, so no scheduled sweep would find it. NIT is the correct rating: real, zero present consequence, and the standing remedy (hoist to Shared/) is cheap.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P42.

#### P43. `EditorViewModel.fanAction` and two `FanPanelState` fields are dead production code, reached only by a test, and every fan-panel open pays a pointless store read

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:2447` · **MINOR** · CONFIRMED · dead-code · finder confidence 0.95

Sitting 9 (R87) retired the FanPanel: the only presenter is EditorView.swift:108-112, `.sheet(item: $model.fanPanel) { panel in WriteTakesPanel(session: session, postID: postID, blockID: panel.blockID) }`, which reads ONLY `panel.blockID` and drives every act through its own `TakesViewModel`. But `loadFan` still performs an async `Queries.blockFan` read and an index walk purely to populate `FanPanelState.variants` and `.chosenVariantID` (EditorViewModel.swift:2338-2347) — `grep -rn "FanPanelState" App/Variorum` returns exactly three hits (the property :106, the struct :217, this construction :2346) and neither field is ever read. `fanAction` (:2447) plus `enum FanAction` (:2480) — roughly 45 lines dispatching eight distinct operations, each `Task { await autosave.flushNow(); ... }` — has one caller in the entire tree: VariorumTests/EditorSessionTests.swift:721 (`refusalsSurfaceAsMessages`), which must hand-construct `h.model.fanPanel = .init(blockID:..., variants: [], chosenVariantID: ...)` first precisely because no UI path can produce it. So the suite guards a door that cannot be opened from the app, and the live delete-take refusal wording is actually produced by a different road (`WriteTakesPanel` → `TakesViewModel.deleteTake` → `OpsRefusalCopy.message`).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over the whole app tree. `fanAction` (EditorViewModel:2447) and `enum FanAction` (:2480) have exactly one caller in the repo: VariorumTests/EditorSessionTests.swift:721, which must hand-construct `h.model.fanPanel = .init(blockID:…, variants: [], chosenVariantID: …)` first. The only presenter is EditorView.swift:108-112, whose comment says "Sitting 9 (R87): the FanPanel is retired" and which passes only `panel.blockID` to `WriteTakesPanel`. `FanPanelState.variants` and `.chosenVariantID` are written at :2346 and read nowhere in production (`chosenVariantID` grep returns only the struct field, the construction, and unrelated Compare/mobile symbols; `variants` is read only in FocusHandoffTests:206). `openFan` IS a live road (button at EditorView.swift:667 plus the routed command at :2331), so `loadFan`'s async `Queries.blockFan` read does run on a real gesture purely to fill unread fields. One correction to the finding's framing, which does not change the verdict: `FanPanelState` itself is not dead — the sheet's `item:` binding uses it, and `blockID`/`id` are live; only the two fields and `fanAction` are. Severity MINOR is right: no user-visible consequence, but ~45 lines of ops-calling code no UI can reach, guarded by a test that reads as coverage of a refusal path the live road (WriteTakesPanel → TakesViewModel.deleteTake) actually produces.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P43.

#### P44. UndoStack grows unbounded for the app session's life and its removeAll() has no production caller

`Sources/VariorumCore/Operations/UndoStack.swift:304` · **NIT** · CONFIRMED · dead-code · finder confidence 0.90

One UndoStack is constructed per AppSession (AppSession.swift:494) and nothing ever trims it: entries has no cap, no age-out and no clear door. `removeAll()` is public but its only callers are UndoStackTests.swift:419 and :498 — dead in production. Entries retain full text: TextPreImage holds both `text` and `postOpText` for each touched variant, and MintedPreImage.birthTexts holds the whole working_text of every minted variant, which for divideDuplicating on a fanned block is every take duplicated onto BOTH successors. A long writing session therefore accumulates two copies of every structurally-touched buffer with no ceiling and no way for the user or the app to release them.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Both halves verified. One UndoStack per AppSession (App/Variorum/Shared/AppSession.swift:494), `entries` has no cap, no age-out and no production clear door; the sole non-register clear is the redo-side removeAll inside undo (:276). `public func removeAll()` (:304-310) is called only from Tests/VariorumCoreTests/UndoStackTests.swift:419,498, RedoStackTests.swift:567 and PoolDragCopyTests.swift:163 — a grep for removeAll() across all of Sources/ and App/ returns no other UndoStack caller, so the public API is unreachable from either app. Retention is as described: TextPreImage carries both text and postOpText (:162-166) and MintedPreImage.birthTexts carries every minted variant's whole working_text (:213-217). Confirming at NIT as filed: per-act cost stays bounded by the edit so P1's letter holds, the stack is session-scoped and never persisted by design, and blocks are paragraph-sized — the accumulation is a real ceiling-less retention plus a genuinely dead public entry point, not a defect a user meets.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P44.

#### P45. BoundarySnapping.snap has zero production callers, yet divide's op doc names it as the boundary contract instead of the settle rule that actually ships

`Sources/VariorumCore/Domain/BoundarySnapping.swift:116` · **NIT** · CONFIRMED · dead-code · finder confidence 0.90

`grep -rn --include="*.swift" "BoundarySnapping.snap\|\.snap(" Sources App` returns exactly two hits and BOTH are comments (Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). The only executable callers are BoundarySnappingTests.swift:178-195. Every shipped door snaps through `settle` instead (StructuralGesturePlanner.swift:200-204, 295-303, 335-338), and the two functions genuinely disagree: `snap` is plain nearest over a Granularity with no pull, `settle` takes an explicit candidate list and applies settlePull, so they return different offsets at every cut where a strong boundary is within 2 units (finding 2's class). INPUT: a session reads `divide`'s doc to learn what a legal cut is. OUTPUT: it learns a rule no door enforces, and `snap` stays permanently green because its own tests are its only users — a public API kept alive solely by its test.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over Sources, App (both Variorum and VariorumMobile) and Tests: `snap(` matches exactly ONE definition (BoundarySnapping.swift:116) and thirteen call sites, ALL of them in Tests/VariorumCoreTests/BoundarySnappingTests.swift:180-213. Zero production callers, on either platform. The only other repo mentions of the symbol are two doc comments (Sources/VariorumCore/Operations/Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). I read the divide doc in full: line 180-183 says boundary discipline is 'deliberately the editor's contract (`BoundarySnapping.snap`)' — and the editor's actual contract is `settle`, per the planner's own three call sites (StructuralGesturePlanner.swift:204, 295-303, 336-338) and BoundarySnapping's own class doc at line 72-73 ('`settle(_:in:among:)` is the one snap brain'). The two functions genuinely differ: `snap` is plain nearest over a Granularity with no pull, `settle` takes a candidate list and applies settlePull, so they disagree at exactly finding 2's class. Real doc drift left by the S4-22 cut redesign, with a public function whose only exercisers are its own tests. NIT is the right severity — no runtime consequence, only a stale contract name a future session would trust.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P45.

#### P46. AppSpec §7's setting-seed comment still says idle_commit_hours = 24; the shipped seed is 2

`Sources/VariorumCore/Persistence/Migrations.swift:790` · **NIT** · CONFIRMED · drift · finder confidence 0.95

seedV1Settings inserts ('idle_commit_hours', '2'), and v1_13_savepoint_backstop moves existing stores off '24'. notes/AppSpec.md §7's setting DDL block still carries `-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','24')`. The 24 -> 2 ruling (13j, J11) is recorded in OverallModel.md §3 and in the v1_13 migration comment, so this is a stale line rather than an open question. A reader cross-checking the DDL against §7 — which CLAUDE.md names as the single source of design truth, and which is exactly what a schema review is instructed to do — reads a default value the store has not had since 13j.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified both sides. Migrations.swift:780-792 seeds `('idle_commit_hours', '2')` and its own comment names §7 as stale, citing the 13j J11 ruling and v1_13_savepoint_backstop for existing stores; MigrationTests.settingsAreSeeded carries an annotated pin at the 2 h value. notes/AppSpec.md:359 still reads `('idle_commit_hours','24')`, and the drift is in fact WIDER than the finding says — AppSpec §9's idleAutoCommit entry (line 419) also still reads "(setting, default 24)", while OverallModel.md:34 correctly records the 24 h → 2 h drop. So the 13j closeout updated OverallModel and left AppSpec stale in two places. No behavioral consequence; purely canon-vs-code drift, which this project does treat as a first-class defect but which costs nothing until a reader trusts §7 over the migration. NIT is correct.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P46.

#### P47. The Mac's whole protection surface has no rendering pin; the ruled 13p disclosures are pinned as string constants only

`App/Variorum/VariorumTests/Phase13pCopySweepTests.swift:86` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.95

Grep over the entire test tree returns zero references to `ProtectionPane`, `StoreLockView`, and `MobileStoreLockView` (only `MobileProtectionSheet` appears, in `MobileTutorialWalkTests`). `Phase13pCopySweepTests.theOpenAppIsReadableLineStatesTheDecline` reads `ProtectionCopy.openAppIsReadable` and asserts its words, and its doc comment claims "the sentence is rendered where a mode is chosen" — but nothing pins the rendering. Delete `ProtectionPane.swift:277` (`Text(ProtectionCopy.openAppIsReadable)`) and the entire repo's tests still pass while the Mac ships its privacy pane without the R13p-16 non-goal disclosure. Identical shape for `ProtectionCopy.deadEnd(_:)`: lines 98-118 pin the per-demand lobby sentence (the acceptance walk's own catch — an impossible-cause line), but its only renderers are `StoreLockView.swift:126` and `MobileStoreLockView.swift:182`, neither hosted in a test, so removing that view from the locked lobby is silent. Not an infeasibility: the Mac suite hosts SwiftUI routinely (NSHostingView in BookOrderConversionTests.swift:330-345, BookViewTests, TakePaneDurabilityTests).

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified by grep over both Mac and mobile test targets: zero references to `ProtectionPane`, `StoreLockView`, or `MobileStoreLockView` anywhere in App/Variorum/VariorumTests, App/Variorum/VariorumMobileTests, or Tests/. The only `MobileProtectionSheet` reference is MobileTutorialWalkTests.swift:1299, and it asserts the static `doorTitle` string appears in tutorial prose — not a rendering pin either. Phase13pCopySweepTests.swift:86-95 reads `ProtectionCopy.openAppIsReadable` and asserts its words while its doc comment claims 'the sentence is rendered where a mode is chosen'; the sole Mac renderer is ProtectionPane.swift:277, unhosted. Same shape for `ProtectionCopy.deadEnd(_:)` (Phase13pCopySweepTests.swift:104-121), whose only renderers are StoreLockView.swift:126 and MobileStoreLockView.swift:182 — the acceptance walk's own catch is pinned at the constant, not at the lobby. The infeasibility defence does not hold: the Mac suite hosts SwiftUI routinely (NSHostingView in BookViewTests, BookOrderConversionTests:332, BookHistoryPaneTests, BookAscentTests). This is a coverage absence rather than a live defect, which keeps it MINOR rather than MAJOR — but MINOR is right, not NIT, because 13p's own claim is that this surface says what is actually so, and the pins fail only when the constant changes, never when the surface stops showing it.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P47.

#### P48. Five of six P1 benchmarks are gated by an absolute 2 ms floor, not the flatness ratio their names claim

`Tests/VariorumCoreTests/PerfBenchmarkTests.swift:57` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.92

`expectFlat` asserts `l <= max(s * factor, floor)` with `factor: 3.0, floor: .milliseconds(2)`. I ran `swift test --filter PerfBenchmarkTests` on this tree (2026-08-30, exit 0, 6/6 green) and read the medians the helper prints. In five of six pins `s * 3` is BELOW the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part: postRender s=0.655 (s*3=1.965), assembleReading s=0.584 (1.752), timelinePage s=0.618 (1.854), library s=0.310 (0.930), tagSubtree s=0.651 (1.953) — all under floor=2.000. Only `autosaveIsFlatInPostLength` (floor overridden to 1 ms, s=1.359 → 4.077) is ratio-bound. Concretely: `libraryPageIsFlatInCorpusTextSize:111` compares a 100x10 corpus with a 100x100 corpus (10x the text) and passes at ANY large-corpus timing up to 2.000 ms against a measured 0.310 ms — a 6.45x tolerated regression, i.e. a query whose cost grows as ~N^0.81 in corpus text ships green under a test named 'IsFlat'. This is the project's only automated P1 guarantee at the query layer and the baseline Phase 12 re-verifies against.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced and re-measured. `expectFlat` (PerfBenchmarkTests.swift:48-61) asserts `l <= max(s * factor, floor)` with factor 3.0 / floor 2 ms. I ran `swift test --filter PerfBenchmarkTests` on this tree (6/6 green): renderPost s=0.639 (s*3=1.917), assembleReading s=0.579 (1.737), timelinePage s=0.574 (1.722), library s=0.320 (0.960) — all below the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part. One correction to the finding's arithmetic: tagSubtree measured s=0.703 on my run (s*3=2.109 > 2 ms), so it flips run-to-run — it is FOUR pins clearly floor-bound plus one marginal, not a stable five. autosave (floor overridden to 1 ms, s=1.343) is genuinely ratio-bound. The consequence stands: `libraryPageIsFlatInCorpusTextSize` tolerates any big-corpus median up to 2.000 ms against a measured 0.320 ms — a ~6x scaling regression passes under a name asserting flatness. Not refutable as a documented tradeoff: the suite docstring claims the opposite of what happens ('absolute timings are machine noise, ratios are the assertion'), and notes/plans/phase-04-read-layer.md:83 likewise reports these as ratio assertions. The project itself already ruled this exact class a defect on the phone — MobilePerfWalkTests.swift's bounds comment, verbatim, 'a pin named "flat" whose floor is the only binding bound is the record-claim class' — and renamed the mobile pins to say which term binds; the core suite never got that pass. Severity MINOR is right: no shipped behavior is wrong, but these six are the only automated P1 guard at the query layer and the baseline Phase 12 re-verifies against.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P48.

#### P49. Nothing pins that a synced table actually has its outbox-capture triggers, so a future table can join the registry and silently never sync

`Sources/VariorumCore/Sync/SyncSchema.swift:8` · **MINOR** · CONFIRMED · test-gap · finder confidence 0.90

SyncSchema.swift's header promises that a table added to the schema 'is added HERE or it silently never syncs (the introspection test in SyncSchemaTests fails the build instead)'. The test that exists, SyncSchemaTests.registryMatchesLiveSchemaExactly:14-33, compares the registry only against the set of sync_version-carrying tables — it never looks at triggers. I searched the whole test tree: `grep -rn "outbox_" Tests/` returns nothing and `grep -rn "type = 'trigger'" Tests/ Sources/` returns nothing; no test introspects sqlite_master for triggers. Concretely, a v1_15 migration that creates `CREATE TABLE foo (... sync_version INTEGER NOT NULL DEFAULT 0 ...)`, adds `SyncTable("foo", ...)` to the registry and "foo" to MigrationTests.expectedTables, but omits `try createOutboxCaptureTriggers(db, table: "foo", pk: "id")`, passes registryMatchesLiveSchemaExactly, everySyncedTableCarriesSyncVersionDefaultZero, everyColumnOfEverySyncedTableIsClassifiedExactlyOnce, mirrorDDLCoversEverySyncedColumn and allTablesExist. Every ordinary write to foo then fails to enqueue, so device A's rows never reach device B and no error is raised anywhere; AccountLifecycleTests:267-273 would not catch it either, because resyncReinitialize enqueues by explicit `INSERT OR REPLACE INTO sync_outbox ... SELECT` (SyncEngine.swift:408-413), not by trigger. The identical gap covers tombstone cascades: nothing asserts a new child table gained its cascade_* trigger.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The gap is real. I grepped the whole test tree: the only sqlite_master introspections are for TABLES and INDEXES (SyncSchemaTests.swift:19, MigrationTests.swift:66/75/93/105, BlockCommentTests.swift:26/32, ReadingSectionTests.swift:42, BridgeStateTests.swift:76) — `type = 'trigger'` appears nowhere in Tests/, and `outbox_` (the trigger-name prefix minted at Triggers.swift:135) appears in no test. registryMatchesLiveSchemaExactly (SyncSchemaTests.swift:16-31) compares the registry only against the set of sync_version-carrying tables, exactly as the finding says. TriggerTests' outbox suite exercises three tables by hand (container, setting, and a block cascade) — never the registry, so a 20th registered table with no trigger pair passes every existing pin. Trigger creation is by hand-maintained list (Triggers.swift:107-125, 13 tables) plus six later per-migration calls (Migrations.swift:168, 256, 257, 299, 362, 465), never driven off SyncSchema.tables, so nothing structurally couples them. Two corrections to the finding's framing, neither fatal: (a) the SyncSchema header's promise is accurately about REGISTRY drift, which registryMatchesLiveSchemaExactly does enforce — the finding reads it as covering triggers, which it does not claim to; (b) today's correspondence is exact (19 registered tables, 19 trigger pairs), so this is a preventive pin, not a live defect. MINOR is the right rating — real, narrow, and future-facing, but the failure mode (a table whose writes never leave the device, silent on both machines) is precisely the class this codebase pins by introspection elsewhere.

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P49.

#### P50. The keyed-store WAL plaintext scan cannot fail — the WAL is checkpointed away before the test reads it

`Tests/VariorumCoreTests/KeyedStoreConvergenceTests.swift:87` · **NIT** · CONFIRMED · test-gap · finder confidence 0.85

Lines 80-81 call `binding.lock()` on both stores, which runs `outgoing.close()` on the DatabasePool (StoreBinding.swift:97). Closing the last WAL-mode connection checkpoints and then deletes or truncates the `-wal`. Line 87 then reads that file with `try?`. Both outcomes are unfalsifiable: if the file is deleted, `try?` yields nil and the `#expect` at line 88 never executes; if it is truncated (the branch I reproduced on this machine — `sqlite3 t.sqlite "PRAGMA journal_mode=WAL; CREATE TABLE x(a); INSERT INTO x VALUES('prose');"` leaves a 0-byte `t.sqlite-wal`), `walBytes` is empty and `range(of:)` is trivially nil. So if SQLCipher ever wrote cleartext into the WAL during operation, this scan stays green, because it only ever looks after the checkpoint. Reading the `-wal` before `lock()` would be the falsifiable order. The store-file scan at line 84-85 is real and unaffected.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Mechanism verified. SyncTestHarness.swift:71 opens the client via `AppDatabase.openStore(at:custody:)`, i.e. `.direct` storage, so `a.db.asRebindable()` (AppDatabase.swift:69-76) mints a fresh StoreBinding over that same writer and `lock()` (StoreBinding.swift:88-102) calls `outgoing.close()` on the pool — the last connection. SQLite then checkpoints and deletes-or-truncates the `-wal`; I reproduced the truncate branch on this machine (sqlite3 WAL write, clean exit, `t.sqlite-wal` left at 0 bytes). KeyedStoreConvergenceTests.swift:86-89 reads that file only AFTER lock(), with `try?`, so either the file is gone (nil, the #expect never runs) or empty (`range(of:)` trivially nil). The scan is unfalsifiable as ordered. Two corrections that lower the stakes: (a) the store-file scan at :83-85 is real and unaffected, as the finding says; (b) contrary to 'the suite claims coverage of a leak path it never inspects', the WAL leak class IS inspected live elsewhere in the same target — StoreEncryptionTests.swift:99-103 scans the `-wal` while the pool is still OPEN, with frames present ('WAL pages encrypt too'). So this is a redundant dead belt beside a live pin, not an uncovered guarantee. Downgraded to NIT accordingly; the honest fix is one line of reordering (scan before lock()).

*No red-on-old pin.* Evidence quotes + verifier trace: review doc, P50.

---

## 17i — Sync across devices: the reconciliation probes, the scenario sweep, the harness-realism fix

**Status: open, unstarted — RUNS AS ITS OWN ENTRY AFTER `pre-13x` (author, 2026-09-01 evening at the Act 10 correction round's sitting, R-cor-13: *"Agree that pre 13x doesn't need 17i to be done within it"* — superseding the morning's pull-in); still on the settled key path, so after pre-13x lands, never before. Earlier wording: PULLED INTO `pre-13x` (author, 2026-09-01 morning: *"I would like to pull 17i into this in between phase"*; it was to run as that phase's LAST batch, on the settled key path — `notes/plans/pre-13x-postures-design.md` §15.6)** (opened 2026-08-31 at the author's word; brief =
`notes/plans/pre-13u-memo-sync-disagreements.md`).

**What it is.** Not a bug list — a HUNT: the memo's four probes run first (each answer recorded in
the memo whether it confirms canon or not), then the scenario table's ✔ rows are re-run under
production's round shape (pull → push, 200-row chunks, interleavings), then every discrepancy found
becomes an item here with the standard trace + red-on-old pin. The structural deliverable is the
harness change: production's round shape becomes the convergence suites' default (a
`productionRound` helper; chunk splits at registry boundaries as a sweep) — the pre-13u ladder's
lesson (R2-1/R2-2 passed in the harness's order and failed in production's).

**First fix item (promoted from the memo's P5(a) at the pre-13u ladder's round 3, 2026-09-01):** the general `tag.path` repair's loss of applications that arrive after the duplicate died — the KnownIssues row carries the mechanism and the pin. **Second structural item (R3-2):** the seed-shape guard invokes the real classifier instead of mirroring its SQL.

**Cast:** Fable (all `Sync/`; the standing rider). **Standing rules:** pin before fix; canon (SyncSpec
§§5–7, §12) outranks the implementation — a probe that falsifies a canon sentence is a finding
against the CODE unless the author rules the sentence wrong. **Related, kept separate:** the
daily-Journal identity memo (13y) and the dedupe's late-registry residual (KnownIssues, 13y).


## 17j — PARKED: the "open your library without Variorum" recipe (may or may not happen)

**Status: parked, unstarted** (author, 2026-09-01: *"I'm not going to worry about a decrypting
script… I'd park them as 17 items or something. they may or may not happen."*). **What it is:** a
published, tested recipe that opens a Variorum library with no Variorum app — the key envelope's
format (`variorum-keys.json`: Argon2id descriptor → RFC 3394 unwrap → the raw 256-bit key) and the
`sqlcipher` CLI's raw-key pragma — plus a ~30-line reference script. **Why it would matter:** it makes
"you own your files" true even if the app vanishes; the plaintext SQLite export (pre-13x, ruling 9)
covers the everyday need, so this is the belt. **Owner if it runs:** its own 17 entry, after pre-13x
(the envelope format is that phase's). Record: `notes/plans/pre-13x-postures-design.md` §4 / §18.

## 17k — PARKED: a plain "Pause sync" switch (may or may not happen) — **JOINS 18a (author, 2026-09-01 evening, R-cor-13: "ask to sync, pause sync button, etc." are 18a's sync considerations); this entry stays as the pointer**

**Status: parked, unstarted — re-homed to 18a's design sitting** (same ruling, same day). **What it is:** a convenience switch on the
sync row that stops rounds until flipped back — NO posture semantics, NO security claim (deletion
damage is already bounded by tombstones, the 30-day Trash on every device, the purge horizon, and
local backups; Castle enrollment needs the passphrase). Cheap: the scheduler's stop + one honest
line on the sync row. Record: `notes/plans/pre-13x-postures-design.md` §14 item 22 / §16(d).

## Not slotted — needs the author's call

### P39. Feature modules call each other directly — 20 mutual pairs, including a hard Library↔Pool view-model cycle and a sibling view model constructed inline

`App/Variorum/Variorum/Features/Pool/PoolPostsView.swift:240` · **MINOR** · CONFIRMED · architecture · finder confidence 0.90

CLAUDE.md binds: 'One feature = one self-contained module... Cross-feature interactions route through parent composition, never feature-to-feature calls.' Measured over Features/*/ with comment lines blanked and generic type names excluded: 20 mutually dependent feature pairs. Confirmed violations: (a) Editor/WriteTakesPanel.swift:51 CONSTRUCTS a sibling feature's view model inline — `TakesViewModel(session:postID:)` — so Editor owns Takes' model lifecycle; (b) Pool/PoolPostsView.swift:240,246 calls methods directly on LibraryViewModel; (c) a hard type cycle — Library/SidebarView.swift:105 holds `let pool: PoolViewModel` while Pool/PoolPostsView.swift:127 holds `let library: LibraryViewModel`; (d) NoteDeletion, an app-wide act, is homed at Features/Library/NoteDeletion.swift:90 and reached from four features (Takes/TakesBottomBar.swift:406,411; Pool/PoolPostsView.swift:179,253; Editor/CommitBar.swift:301,311). Consequence: no feature can be changed, tested, or reviewed in isolation — a lifecycle change to PoolViewModel lands at a Library call site a Pool-scoped reviewer never opens, and the reverse. For (d) specifically, the next door needing note deletion must either import a feature or copy the act.

**MEASURED 2026-08-30, and the finder's headline was WRONG.** The finding claims "20 mutual pairs";
a direct measurement over `Features/*/` (uniquely-owned type names >5 chars, comments stripped) gives
**57 directed cross-feature edges across 8 mutual pairs**, not 20. The verifier had already tempered
the finding on three other counts: **(a)** parent composition IS honoured — `RootView.swift:133,557`
are the only construction sites, so what is violated is the *"never feature-to-feature calls"* half,
not the composition half; **(b)** the class is already enumerated in
`notes/plans/phase-13b-stage0-architecture-survey.md` §8.1, including `WriteTakesPanel`'s
`TakesViewModel` ownership by name — so it was never unknown, only unowned; **(c)** the `NoteDeletion`
limb is REFUTED on merits — the App target is a single Swift module, so there is no import cost and
the objection reduces to folder placement.

**What the 8 mutual pairs actually are** — and they are three different things wearing one label:

| Pair | What crosses |
|---|---|
| `Library` ↔ `Pool` | **VIEW MODELS, both directions** — `PoolViewModel` ← Library, `LibraryViewModel` ← Pool, plus Pool calling `library.duplicateAsVersion` / `library.archive` directly |
| `Editor` ↔ `Takes` | Editor **CONSTRUCTS** `TakesViewModel` inline (`WriteTakesPanel.swift:51`); the rest is shared components (`LensNameSheet`, `TakeClipboard`, `CalloutMenu`, `CommitBar`) |
| `BookView`↔`Takes` · `Canvas`↔`Pool` · `Canvas`↔`Takes` · `Editor`↔`Tray` · `Library`↔`Takes` · `TOC`↔`Takes` | A view rendering a sibling's view, or a small shared type homed in a feature folder (`TakeEditCost`, `TagChips`, `MembershipChip`, `NoteDeleteConfirm`, `BlockTOCView`) |

**So the real defect is TWO items, not fifty-seven:** the `Library` ↔ `Pool` view-model cycle, and
Editor owning `TakesViewModel`'s lifecycle. Everything else in the tail is **a shared component living
in a feature folder instead of a shared home** — placement, not architecture, and in a single-module
target it costs nothing at runtime.

**A rule violated 57 times is usually a wrong rule.** This project's own doctrine says an operation
tortured to express means the schema is wrong, not the operation (OverallModel §9). The same logic
applies here: CLAUDE.md's *"never feature-to-feature calls"* is, as literally written, violated by
ordinary SwiftUI composition — one view rendering another. The rule almost certainly MEANS *view
models and business logic never cross features*, which is a rule the code nearly keeps.

**Why it is NOT an entry.** Everything else in this file is a bounded fix with a settled shape.
This one needs a **decision before it needs work** — specifically, whether the canon rule it cites
means what it literally says. Scoping an entry against a rule that is about to be refined would build
the wrong thing. Once the rule question is answered the *work* is small (the two real items), and it
should become an ordinary lettered entry at that point.

**The options, hers to choose** (recommendation: C+B):

- **(A) Full untangle as its own post-launch phase** — all 57 edges, every shared component moved to a
  shared home, both view-model cycles broken. High file churn, zero user-visible benefit, real
  regression risk in a tree whose editor seam is the project's #1 stated risk. Only defensible
  post-launch, and probably never worth it on its own.
- **(B) Fix the two real ones as an ordinary entry; record the tail.** Break `Library`↔`Pool` (Pool
  stops holding `LibraryViewModel`; its two calls become closures passed by `RootView`) and stop
  Editor constructing `TakesViewModel`. Small and contained. The component tail becomes a KnownIssues
  row, fixed opportunistically as phases touch each one.
- **(C) Refine the rule to what it means, and record the rest as deliberate.** Amend CLAUDE.md so the
  prohibition binds **view models, business logic and lifecycle ownership** — never a view rendering a
  sibling's view, and never a shared component in a single-module target. Then the tail is not debt at
  all; it is the rule, correctly stated, and the next sweep stops re-reporting it.
- **(D) Do nothing, unrecorded.** The one bad option — a blank owner is what this project's rules
  forbid, and 13b's §8.1 survey already proves this class comes back when it is merely written down
  somewhere that closes.

**C first, then B:** the rule refinement costs minutes and shrinks the problem from 57 to 2; the two
survivors are then a small entry against a rule that is actually true.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every cited line is real. WriteTakesPanel.swift:51 does `_model = State(initialValue: TakesViewModel(session:postID:))` — Editor constructing Takes' VM. PoolPostsView.swift:127 holds `let library: LibraryViewModel` and calls `library.duplicateAsVersion` (:240) and `library.archive` (:246); SidebarView.swift:105 holds `let pool: PoolViewModel` — the type cycle is real. CLAUDE.md/AppSpec §2's rule is quoted correctly. THREE CORRECTIONS. (a) Both cycle halves ARE wired by parent composition — RootView.swift:133 and :557 are the only construction sites — so what is violated is the 'never feature-to-feature calls' half, not the composition half. (b) The class is already documented: notes/plans/phase-13b-stage0-architecture-survey.md §8.1 'Cross-feature coupling' enumerates it including WriteTakesPanel's TakesViewModel ownership by name, and 13b acted on one instance (the plan's Canvas row said 'stop calling TakesViewModel.message(for:) cross-feature' — grep confirms CanvasView no longer does). So already_known is wrong. (c) Item (d) is REFUTED on its merits: NoteDeletion is a static act namespace whose own header documents 'Four doors reach this act' and why it is one file; the App target is a single Swift module, so no import cost exists and the objection reduces to folder placement. Severity down to MINOR: no invariant (I/P/S) is violated and no user-visible behaviour is wrong; this is maintainability, and the claim 'no feature can be changed, tested, or reviewed in isolation' is overstated.

*No red-on-old pin.* Full evidence: review doc, P39.



---

## 17g — The macOS data-protection keychain asymmetry (the 13p-fix session)

**Status: CLOSED 2026-08-30**, three review rounds, all-Opus cast at her
instruction. **The full record is `notes/plans/phase-13p-fix-dp-keychain.md`**
— the FINDING with its measurement, the fix design, the ledger, the batch
record, and all three ladder rounds. This entry is the summary and the
hand-offs.

### What she hit

Minutes after 13p's signing gap closed, she ticked *"Require Touch ID to
unlock sync"*, it silently reverted, and then: *"i tried opening variorum
and the touchid didn't work, even though i enrolled it, and then i
entered my passphrase, and then i had to enter it again to get sync to
start working."*

### The mechanism, measured

On macOS a keychain write carrying an access-control (biometry) ACL or
`kSecAttrSynchronizable` is routed to the **data-protection** keychain,
while a read without `kSecUseDataProtectionKeychain` searches the
**file-based** one. That flag appeared **nowhere** in the codebase.
Measured in the signed test host: `add 0` · `read-without -25300`
(itemNotFound) · `read-with -25308` (present, needs auth).

**Latent until that afternoon.** Before the signing gap closed, every
ACL'd write died at `-34018`, so the gated paths never once succeeded and
the asymmetry could not bite. Closing the gap did not break something
that worked — it made a latent defect reachable. **iOS was never
affected** (it has only the data-protection keychain).

**Why it cost her custody rather than just failing.** Both gated
transitions delete the surviving plain item immediately after a
"successful" gated write. So her Biometric-mode switch wrote an
unreadable gated store key and deleted the Auto item, and the sync toggle
did the same to her E2EE custody. Both recovered by passphrase; no
writing was ever at risk.

### What shipped

- **The flag on the three query builders** that own every DP-resident
  site, behind one named constant (`KeychainPartition.dataProtection`)
  rather than a comment pasted three times.
- **`CustodyHandover`** — the rule the incident actually demanded: write,
  **verify it reads back through the production read path**, only then
  delete the outgoing item; typed outcomes so the arm where something
  *did* land somewhere unreadable stops claiming "nothing was altered".
  Both custody transitions and both surfaces now speak it.
- **Pins:** the platform fact; a production round trip (write → find →
  delete → confirm gone); three direct outcome tests; two E2EE transition
  pins; a structural guard covering all three families. Every bug-class
  fix red-on-old by **behavioural revert**, not assertion.
- **Counts: Mac 1854 / 314 — ALL PASSED** on the final tree, canvas
  flake included (baseline 1843/312; +11 tests, +2 suites, arithmetic
  checked). Zero `Sources/VariorumCore/Sync/` lines, zero schema, no
  lockstep — marker stays 7.
- **`/Applications` refreshed** behind the A1 rail (ciphertext backup
  first, hash-matched install, keychain identity and the new refusal copy
  both confirmed in the shipped binary), so her E2EE re-enrollment lands
  on the guarded build.

### The three rounds, in one line each

**Round 1 (14 findings)** — the phase had fixed the CAUSE and left the
FAILURE MODE: both transitions still deleted the plain item on a write's
word alone. Also falsified two of the phase's own claims (the escrow leg
of the diagnosis was simply wrong; the batch record asserted facts about
her live custody it had just proved unobservable).

**Round 2 (1 MAJOR)** — round 1's revert drill proved the *store-key*
guard and the record claimed "both proven". The **E2EE** guard had no pin
of any kind — and that is the half whose item actually went missing.

**Round 3 (3 MAJOR)** — and the sharpest finding of the phase was against
the phase itself: see below.

### ⚠️ The phase broke its own trap — recorded because that is the point

Round 3 caught that the round-2 revert drill **removed the injected
seam's use**, so the "fake-driven" E2EE pins fell through to the real
`E2EEKeychainStorage` at its fixed account and **overwrote her live E2EE
custody with test material**. Verified from the live Keychain: the item
was created inside the drill window, and a read of its key *identifiers*
(never its bytes) returned the drill's sentinel exactly.

Consequence: **sync refuses until she re-enrolls with her passphrase** —
the designed road, walked once already that evening, nothing at risk
because the vault is server-side. An attempt to clean it up was correctly
**blocked by the permission classifier** (deleting a keychain item via
the test runner is a non-test action), and routing around it would have
been the wrong move, so it was left to her with both roads written up.

**The rule taken, now in the plan's ENVIRONMENT TRAPS in bold: a revert
that removes an injected seam is never a valid drill.** Revert the
outcome check instead — same red, zero real-world traffic.

### Handed off, every item owned

| item | owner |
|---|---|
| Should the store key be BOUND to this device? (its protection class is inert on macOS, so the key rides Migration Assistant to other hardware — two production comments claimed otherwise until now) | **QUESTIONS #82**, hers; KnownIssues at **13x** |
| Deletes discard their status; `E2EECustodyStorage.live`'s wiring untested; `setMode`'s synchronous `SecItem*` on the MainActor; the test's global cache write | **17a** |
| The escrow round trip has never been verified on any machine | **13x** |
| A Developer ID build must carry the same `keychain-access-groups` | **13r** |
| `saveGated`'s forced delete-then-add window (pre-existing since 14b) | **17a** |
| `CanvasDragTrackingTests` load flake (found, not caused; both its tests) | **12** |
| The `wroteButUnreadable` wording | **13s** voice pass |

### Owed to the author

1. **Re-enroll E2EE with your passphrase** (my drill's damage — see above).
2. **The two-step clean-up** if the biometric-gate orphan is still there:
   unlock FIRST, then toggle off. The one-step version refuses.
3. **QUESTIONS #82.**
4. **The install refresh — DONE at the CLOSE (`8490ac3`):** `/Applications` was refreshed behind the
   A1 rail, hash-matched, the guard confirmed in the shipped binary. *(This item predated the CLOSE
   and stood uncorrected beside it — struck at the pre-13u round's Act 1 cold review, finding F3.)*

---

## 17h — The custody riders 17a never listed (R2-7 · R3-5 + riders)

**Status: CLOSED 2026-08-31 — the pre-13u round's small fresh Fable session,
commits `73763c2` (R3-5 + R3-4) · `bc48315` (R3-6) · `98813d4` (R2-7) + the
records commit on `main`.** Both items FIXED; every bug-class pin red-on-old
by a faithful **behavioral revert** (the R3-1 rule — the outcome check
reverted, never the seam; each drill red reproduced the traced end state
verbatim). Zero `Sources/VariorumCore/Sync/` lines, zero schema. The two
`KnownIssuesAndTechDebt.md` rows that named this entry are REMOVED per that
file's rule; this entry is the resolution record.

### Dispositions (per item)

| item | verdict | pin(s) | notes |
|---|---|---|---|
| **R3-5** (the delete-status-discarded family) | **FIXED** | `CustodyHandoverTests.aRefusedOutgoingReleaseBacksTheTransitionOut` · `.aRefusedPlainReleaseBacksTheGateOnTransitionOut` · `CustodyReleaseTests` (all three shapes) | Every delete seam answers RELEASED (deleted, or never there): `StoreKeyGuard.deleteAuto`/`deleteGated`, `E2EEKeychainStorage.deletePlainItem`/`deleteGatedItem`, core's `StoreKeyKeychain.delete` (both keychains, both legs). `CustodyHandover` consults its delete leg — the new `.outgoingNotReleased` outcome rolls the incoming item back best-effort and refuses whole; `setMode`'s `.passphrase` arm verifies BOTH releases (gated first, so a refusal leaves a coherent state from either direction); both surfaces word the arm (`ProtectionCopy.outgoingCustodyNotReleased` / `syncKeysOutgoingNotReleased`, the F6 own-sentence precedent). The `deletesSucceed` knob (the `savesSucceed` pattern) drives the pins. Drill red: every transition COMPLETED with the dial flipped over an unreleased item — the row's three shapes verbatim. **Scope note:** `deleteEscrow` deliberately not widened — the row named `deleteAuto`/`deleteGated` and all three reachable shapes; the escrow item's consistency has its own verified-landed observable (R-pre13u-4), and its delete's failure mode (a lingering RECOVERY copy) is the opposite polarity of custody loss. |
| **R3-4** (rider: `E2EECustodyStorage.live`'s wiring covered by nothing) | **FIXED** | `CustodyHandoverTests`' five wiring pins (`gateOnReleasesThePlainItemAndOnlyThePlainItem` &c.) · `KeychainTripwireTests.theLiveLeavesReachTheStaticFunctionsTheirNamesClaim` | The composition is seamed: `E2EECustodyLeaves` (the fixed-account leaves as closures) + `E2EECustodyStorage.wired(leaves:)` with `.live = wired(leaves: .live)`. The handover ROLES are pinned with recording leaves — transposing `deleteOutgoing`/`rollBackIncoming` in `wired` reds on names; the NAME→FUNCTION mapping is pinned through the tripwire's new `refusedLeafNames` observable with zero Keychain traffic (containment over per-call deltas, race-safe by construction). `KeychainTripwireTests` is `.serialized` now — its exact `+5` count and the new tripper must not interleave. |
| **R3-6** (rider: `setMode`'s synchronous `SecItem*` on the MainActor) | **FIXED** | `ProtectionSetModeOffMainTests.everyTransitionArmsGuardSeamWorkArrivesOffMain` | The transition's custody choreography extracted verbatim into the nonisolated `transitionCustody`, run in ONE hop on a SERIAL custody queue (the `DeviceKeyStore.custodyQueue` pattern — the pre-fix MainActor body had no suspension point across its custody work, so transitions never interleaved; the serial queue keeps exactly that, where a detached task per call would not). Custody semantics byte-preserved — the existing transition pins rode unmodified. Drill red: all three arms' calls landed main-thread while every call-order assertion stayed green. |
| **R3-NIT** (rider: `CustodyHandoverTests` cache save/restore) | **ALREADY DISCHARGED** — Act 9 group 1 (`270bf4f`); not redone | — | Verified present in the test (`E2EELaunchKeyCache` save/restore around `theE2EEGateTurnsOffOnlyWhenThePlainItemReadsBack`). |
| **R2-7** (the `saveGated` delete-before-add window) | **FIXED — probe-first narrowing; the residual window RECORDED, not claimed fixed** | `GatedSaveChoreographyTests` (4 pins) · `Phase13pKeychainFactTests.aGatedReSaveOverAnExistingItemLandsAndLeavesNoProbeLitter` (real DP keychain, signed host, throwaway scope) | **The traced mechanism:** both `saveGated`s ran delete→add (FORCED — updating an ACL'd item demands interactive auth; a write must never prompt), so an add failing after the delete left ZERO gated custody. The reachable harm road is E2EE's `DeviceKeyStore.save` under gate-ON (a passphrase re-unwrap's re-save); the store-key family reaches `saveGated` only from `setMode(.biometric)`, where the custody law keeps the gated item absent — unless an earlier delete failed silently, which is R3-5's third shape, now closed. **Why not the row's swap remedy:** renaming an ACL'd item (`SecItemUpdate` of its account) is an update too and demands interactive auth under the same platform rule that forced delete-then-add — the swap is unsound, and would additionally need crash-heal state machinery in the most safety-critical file. **The fix:** `GatedSaveChoreography` (ONE brain, both families): sweep probe litter → add a PROBE item (sibling account, same service/ACL/DP partition, dummy bytes) proving the keychain accepts an identical ACL'd add RIGHT NOW — identity/access group, DP admission, ACL acceptance, biometry state, disk, securityd — → sweep it → VERIFIED release (R3-5's semantics) → real add. Drill red: the pre-fix body (delete-then-add through the seam) left `existing == nil`, the traced zero-custody end state. **What survives, pinned as documented behavior** (`aFailureBetweenTheTwoAddsStillStrandsAndThatIsRecorded`, green on both trees BY DESIGN): a transient failing between two identical adds milliseconds apart, and the crash-between-syscalls window that always existed — in both, the material is in hand at the caller, the surfaces already word the refusal, and the vault re-derives custody by passphrase (a re-enrollment prompt, never lost writing). No further remedy exists under the never-prompt rule; not deferred work, so no KnownIssues row remains. |

### Verification at close

Core `swift test`: **1457/154 GREEN — exact baseline.** Full Mac suite (run
ONCE, at close): **1887 tests in 320 suites — count arithmetic EXACT**
(baseline 1871/317 + this entry's 16 pins across 3 new suites), green
except the ONE known intermittent latency pin
(`EditorWindowSmokeTests.rewriteStrategyLatencies(paragraphs: 250)` at
54.87 ms in-suite; re-run ISOLATED per the standing rule three times:
51.54 / 53.20 / 51.07 ms — the exact band its KnownIssues row records
across three prior phases' loaded boxes). **Adjudicated PRE-EXISTING on
the diff fact:** this entry's whole diff is 13 keychain/custody files +
test pins, zero editor-path lines (diff-verified), and the row's 13p-close
covariate — the author's LIVE real-store app running beside the test
host — was active throughout; the row stays at its owner (12,
perf-budget calibration). `CanvasDragTrackingTests` (the other known
flake) passed inside the full run. Tutorial spine: **all 10 tutorial
suites GREEN inside the full run.** iOS target **BUILDS**
(`generic/platform=iOS Simulator`; the scheme's default destination
resolves to "My Mac" and fails on provisioning — a destination artifact,
not a compile failure). Zero `Sync/` lines, zero schema (diff-verified:
no file under `Sources/VariorumCore/Sync/` in any commit). The author's
real-store app was RUNNING throughout — never touched, no Release
builds, no `/Applications` refresh.
