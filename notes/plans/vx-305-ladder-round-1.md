# VX-305 — Castle rebuild phase 1: cold review, ladder round 1

**Reviewer:** fable-reviewer (fresh session, zero implementation context), 2026-10-16.
**Prompt:** `notes/REVIEW_PROMPT.md` verbatim. **Diff reviewed:** `git merge-base origin/main HEAD`..HEAD on
`vx-305-castle-core` — 85 files, +27,253 (the whole `Sources/VariorumCore/Protection/` subtree, its test world under
`Tests/VariorumCoreTests/Protection/`, VX-345's three `#if DEBUG` test guards, the plan file). **Canon read in
full:** the binding design `notes/plans/vx-266-castle-backups-prelaunch.md`, `notes/SyncSpec.md`, the phase plan with
all four unit records and her rulings, `Posture.derive` in `App/Variorum/Shared/StoreProtection.swift` (the
transcription oracle), the REVIEW_PROMPT's standing canon. The plan carries no "Review foci" section.

**Verification runs made by this reviewer (not trusted from the record):**
- Scope re-verified by diff: outside `Protection/`, only the plan file and the three `#if DEBUG` Markdown-test guards.
  Zero `Sync/`, `App/`, `Server/`, `Persistence/`, migration or `Package.swift` lines. No new dependency.
- The protection set, Debug: `✔ Test run with 413 tests in 65 suites passed` — the record's exact count.
- Release configuration spot check (`swift test -c release --filter KeyFileWrapTests|CastleAnchorTests|RecordModelTests|RouteFinderRoadTests`):
  `✔ Test run with 37 tests in 8 suites passed` — the release road compiles and runs.
- The soak road, determinism: seed 13 × 20 sequences run twice — `869 steps` both times, green (the record's
  full-seed row was re-verified to the step by the orchestrator; this confirms the mechanism independently).
- `LegacyModeReader` diffed by hand against the live `Posture.derive` (StoreProtection.swift:85–119): the arms,
  `localReading` and `shapeReading` match line for line, corner 45's silent-item case included.

---

## Findings

**[MAJOR] · Sources/VariorumCore/Protection/Executor/PlanRunner.swift:549–578 (rollBack) with
Sources/VariorumCore/Protection/Assess/Assess.swift:279–290 (restoreKeyFileFromCopy's gate) · a plan-less rollback
can leave ANOTHER key's file in the live place with no repair that ever restores the current key's own file — every
later act that needs the live key file refuses `noLiveKeyFile` forever (VX-235's unfinishable class, returned by a
new door) · EVIDENCE (traced):** a re-key (Use Standard from Castle, or Use Castle) crashes after its `keyFile` step
— the NEW key's file now sits in the live place, the library still under the OLD key, the plan on disk mid-act. A
login-password holder then (1) deletes the memory item (`Tamper.deleteMemoryItem` — the sealed mirror goes with it)
and (2) replays an EARLIER act's genuine captured plan over the live one (`Tamper.replayPlan` — it verifies through
the history but fails `isNamed`, a different sequence). At the next open, `settle` reports `.planIgnored(.notNamed)`
(PlanRunner.swift:349–351), falls to the plan-less path, and `rollBack(&library, act: inFlight.act)` runs with
`outgoingKeyFile: nil` (PlanRunner.swift:373): the restore list `[library.memory?.keyFileMirror, outgoingKeyFile]`
is empty, so PlanRunner.swift:555–558 leaves the new key's file live. From then on nothing converges: the rebuilt
memory's mirror stays nil (`memoryValue` mirrors the live file only when it is the current key's —
Executor.swift:325), `restoreKeyFileFromMirror` needs the deleted mirror, and `restoreKeyFileFromCopy` fires only
when `liveKeyFile(facts, unlocked) == nil` (Assess.swift:281) — the live place is occupied, so it never does. Every
act with `needsLiveKeyFile` (Use Castle, Use Standard, Replace All Keys, the follow, the key doors, the leaves) then
refuses `noLiveKeyFile` at `perform` (PlanRunner.swift:231) permanently. The design's own sentence — "a missing or
unmatched plan never blocks" (§3.6) — is contradicted for every FUTURE act; and §3.3's "Always: the record, what
this Mac remembers and the key file agree" has no arm for this state. The scenario checker is structurally blind to
it: the act rolled back (promise 6 satisfied), the library opens (promise 5), no mode changed (promise 4) — so the
898,884-step soak proves nothing about this corner. In the Use-Standard variant the state is at least VISIBLE
(`Fault.appleWrapOnCastleKey` fires on the stray Standard file, Assess.swift:394, and owes `rekeyForFault` — which
no act can answer, since every re-key act needs the live key file); in the Use-Castle variant it yields only a
perpetually-skipped `landAppleWrap` repair. Honest annotation: reachable only by an adversary who holds the login
password AND acts inside a crashed re-key's window (two tampers); the exposure is availability of the protection
acts, never content — the library and every copy keep opening. But the person attacked can never again enter or
leave Castle on that Mac, and nothing says why. **FIX:** extend `restoreKeyFileFromCopy`'s gate (or give
`restoreKeyFileFromMirror` a third arm) to cover "the live place holds another key's file, nothing in flight, no
mirror of the current key": restore the newest catalogued frozen key file of the CURRENT key — the identical
precondition class the both-deleted repair already trusts — with Apple wraps stripped as there. (A cheaper
half-measure — passing the verified-but-not-named plan's `outgoingKeyFile` into settle's plan-less `rollBack` — does
not close it: the replayed plan is an earlier act's and carries the wrong file.) **PIN (red on this tree):** a fixed
scenario — act A crashed (its plan captured at the relaunch), settled; a leave crashed after its `keyFile` write;
tamper `deleteMemoryItem`; tamper `replayPlan` (the earlier capture); relaunch and settle (rolls back); then
`useStandard` → today refuses `noLiveKeyFile`; with the repair it runs. Green-on-both would expose the finding as
hollow; the trace above says it will not be.

**[MINOR] · Sources/VariorumCore/Protection/Assess/Assess.swift:393–395, 430–443 ·
`castleRepairs`/`standardRepairs` reason over the live key file without checking it is the CURRENT key's — wrong
diagnoses in the another-key's-file state · EVIDENCE:** `liveKeyFile(facts, unlocked)` returns whatever format-3
file sits in the live place, whatever key it belongs to. In the MAJOR's state: (a) `castleRepairs` raises
`Fault.appleWrapOnCastleKey` for a file that is NOT the current (Castle) key's — the fault's wording and its
`rekeyForFault` answer misdescribe the state (the current key has no Apple wrap; the file is simply not its); (b)
`standardRepairs` appends `.landAppleWrap` keyed on another key's file's missing wrap — the executor's precondition
(`live.fingerprint == library.fingerprint`, ExecutorRepairs.swift:173) correctly refuses it every time, so no wrong
write can land (defense in depth holds), but assess owes a repair forever that can never run, and `appleRoadLost`
reads the wrong file's wrap. No wrong write is reachable (the executor's preconditions catch every arm I traced), so
this is diagnosis quality, not a safety hole. **FIX:** in `repairs`, compute `live` as the live file ONLY when
`live.fingerprint == unlocked.currentFingerprint` (one guard at Assess.swift:303), and surface the mismatch as its
own typed fault ("the live place holds another key's file") — which is also the MAJOR's honest face. **PIN:** a unit
test on `assess` with a catalog whose live file is another key's: today it emits `appleWrapOnCastleKey`/`landAppleWrap`;
after the fix, the new fault and neither of those.

**[NIT] · Sources/VariorumCore/Protection/Executor/Acts/DeviceActs.swift:20 and 37–38 · dead code: the early
`if step == "memory" { return try ctx.rememberNewKey() }` makes the switch's `case "memory"` unreachable ·
EVIDENCE:** the early return (the plan-less finish's guard against needing `wanted`) runs for the ordinary flow too,
so the duplicated case below never executes. Clarity only — remove the switch case or fold the early return into it.

**[NIT] · Sources/VariorumCore/Protection/Executor/Acts/SharedKeyAndRelink.swift:69 · the doc comment cites
"PROVISIONAL P-U3-7" for the library arm's skip-and-report call; the U3 record numbers that call **P-U3-5** (P-U3-7
is the no-repair-while-act-in-flight call) · EVIDENCE:** the phase plan's U3 record, P-U3-5 vs P-U3-7. A reader
chasing the provisional lands on the wrong ruling. Fix the number.

**[NIT] · Sources/VariorumCore/Protection/Model/DeviceSection.swift:420 · `takingOver`'s no-predecessor STANDING
old-shared pick is `allSections.compactMap(\.oldSharedKey).first` — order-dependent where two sections list
DIFFERENT standing old-name ids (two Macs that lived on different Apple IDs) · EVIDENCE:** `first` over the record's
section storage order; the retired-pick arm just above sorts (`min(by: retiredAt)`), this arm doesn't. Deterministic
per record bytes (the record travels as one file), so no convergence bug — but the choice is unprincipled; prefer
highest version or smallest id, as the sibling arms do.

**[NIT] · Sources/VariorumCore/Protection/Assess/Assess.swift:148–167 (touchID) · with the key file AND the memory
item both deleted (a listed tamper; the fixed scenario `theKeyFileAndTheMemoryItemBothDeleted`), the pre-unlock
`slotFingerprintHint` is nil, so `itemExists` reads false and the quiet line says "Touch ID isn't set up for this
library" while a Touch ID item exists and opens · EVIDENCE:** `fingerprint = unlocked?.currentFingerprint ??
slotFingerprintHint` (Assess.swift:149) — both sources are gone pre-unlock; `LobbyRoads.custodyItems` still
enumerates the item (the library opens through it, and `restoreKeyFileFromCopy` then heals the hint), so this is a
transiently wrong face line, not a lost road. Phase 2's lobby wiring should read `custodyItems` for the button's
existence (VX-310's letter is "whenever a Touch ID item exists"), or the quiet line should soften when custody items
exist whose fingerprints can't be matched. Recording it now so the face isn't wired to `button` alone.

---

## Clean bill — load-bearing things specifically checked and found solid

- **Scope and hygiene:** the branch touches exactly `Protection/` + its tests + the plan file + VX-345's three test
  guards (verified by diff). No `Sync/` line (the vault is modelled from `KeyVaultFormat` in `Crypto/`, as the plan
  requires). No new dependency; no `fatalError`/`try!`/`as!` in the sources; the one force-unwrap
  (PlanRunner.swift:476) is guarded by its `where` clause.
- **The guards' Release posture:** every off-switch exists only under `#if DEBUG`; every `…On` accessor is a
  constant `true` in Release (ProtectionGuards.swift read in full) — the phase plan §2's rule exactly.
- **The seal (§3.6):** HKDF(ikm: L, salt: libraryID, info: "variorum.seal.v1:"+purpose) → HMAC-SHA256; verification
  over the STORED canonical bytes, never a re-encode; constant-time MAC compare; purpose and library bound into the
  key so a value can't verify across purposes or libraries. The reach-based verify (history, silent custody) cannot
  hand an attacker a forgeable sealing key in confirmed Castle: the history needs the current key, custody is swept,
  and corner 45's unconfirmed case is explicitly outside the Castle claims (checked arm by arm).
- **The anchor (§3.4, her rulings):** AES-256-GCM with AAD binding the outgoing fingerprint; locks RFC 3394;
  birth-time locks only, no re-lock API; the pressing device P+W, the follower typed-secret + outgoing-key with
  copied locks and the master road left out when unchanged; kept anchors ride whole and re-seal at the next leave;
  `directFingerprints` keeps promise 9 honest for nested anchors. `KeyFileCrossings`: entering takes everything (an
  unopenable anchor kept, never failing the entry), within-mode carries the anchor, leaving takes nothing with the
  anchor written FIRST and enforced (`anchorNotWrittenFirst`), a re-key drops the old shared wrap, entering Castle
  refuses an Apple lock.
- **The hardware marker (VX-340, her split ruling):** two salted HMAC parts, domain-separated and length-prefixed;
  `MachineIdentity` is not Codable and prints redacted; `resolveIdentity`'s six-rule order matches the ruled
  semantics (continuing → found-by-marker → another-login-adopts-nothing → replacement-by-memory →
  replacement-by-login-part (P-U4-14) → fresh), and the takeover adopts exactly §3.5's three sets.
- **The legacy mode reader:** verified by this reviewer against the LIVE `Posture.derive` line for line; the
  exhaustive-space agreement test (5×4×3×3×2 inputs) plus the honest hand-forward of the app-target oracle to
  phase 2. The two-homes reconcile (newer wins, retirements and the tree union), `FamilyTree`'s normal form and
  commutative/associative/idempotent union, and the record's exact-section replacement all read correctly.
- **The executor's order:** prepare-then-commit exactly as §3.4 (custody item → key file → stage → record into
  staged → swap → memory → old custody), copies paused prepare→swap and re-paused on a resume; the rotation's first
  write stamps `newCorpusKeyID` in the plan BEFORE the vault write; VX-109's door revision taken at the door;
  decision 30 at Replace All Keys' door; decision 35 checked at act level with the leave's local-from-the-swap and
  the held landing's exemptions; the leave's completing write gated on the named key with the minter's own-lost and
  finish-door mints; `pastCommitPoint` is ONE function read by both the executor and promise 6 (her stuck-leave
  ruling as specified). The settle's planted/replayed/unnamed plan handling, the no-identity restore from the plan's
  `outgoingKeyFile`, and the stray-staged-file discard all match the record's U4 fixes.
- **Repairs:** every delete behind an executor-verified precondition (history opened with the current key, the
  mirror's byte-identical lock, the item still holding the key); none while an act is in flight; no repair makes a
  Touch ID item or acts destructively on a Standard record's word; delete-on-sight by recorded id only; Apple wraps
  never re-added by any restore. The memory-wins repairs read only THIS Mac's own memory (seed 17's fix, verified in
  code).
- **assess is pure** (plain values in/out, no leaf calls), and the door table matches §3.8/§3.9/§3.5 point 4 —
  including the signed-out one-road redirects, corner 45's Use-Standard-as-key-change, the finish-leaving door
  standing whether or not the named key reads here, and P-U2-4's signed-out door stop.
- **The catalog and retention:** one strict name parser (stamps must round-trip byte-exact; the A1 rail's names and
  every unknown name are foreign, listed, never touched; neighbouring scopes can never parse as ours — checked
  against hyphenated-scope collisions); attribution per library (serving key file) and Mac (`<mac8>` subfolder, a
  container file by place, a far-folder file unattributed); retention per library per Mac with today's 14/14+4 rule
  restated and undated copies never pruned.
- **The route finder:** names only provable roads (`.current` resting on the fresh-descriptor invariant the executor
  enforces at every new passphrase — verified at `freshPassphrase`/`mintPassphraseKDF`; `.of(day)` earned only by an
  anchor's typed-and-verified locks; `.heldHere` for frozen/copied locks); the unpinned copy's intersection rule;
  the retirement's with/without-the-old-key difference reading; the anchor sentences never pointing at a forgotten passphrase.
  Promise 9 WALKS every named route with the real secret of its day — the honesty claim is mechanically enforced.
- **The scenario world bites:** it drives the REAL executor and `assess` through real acts over dumb fakes built
  from the measured Apple facts (Touch ID items invalidated-not-deleted, iCloud propagation/off-switch/same-name,
  Time Machine, CAS vault); the attacker reach is a genuine key-closure engine with the stated exceptions taken out
  of the seeds clause by clause; the 52 found-and-fixed code bugs and the per-commit red-on-old pins are evidence the
  checker is not hollow. The mutation-pin harness asserts guarded-green AND unguarded-fail in the same test, so a
  green pin IS the red-on-old proof. The generator is seeded, deterministic (verified: identical step counts across
  two runs) and shrinks to minimal sequences.
- **The scans:** no secret, no raw identifier, no unsalted identifier hash, no marker part and no salt outside their
  homes, in every stored value (raw/base64/hex containment, with a positive control); the executor's log and typed
  Diagnostics carry none of them (the log scan runs every act family).
- **Counts and claims re-verified:** Debug 413/65 exact; the release road green on a spot filter; the soak slice
  deterministic; §6's scenario list maps to named tests (sampled broadly — the supersessions and beyond-scope
  markings match her legacy-cut rulings); her 13/13 sitting rulings (P-U4-2 leave sweep, P-U4-4 file-says-birth,
  P-U4-9 inherit-from-any-entry, P-U4-15 wait-not-rollback, the marker split, the stuck leave) each located in code
  and matching as built.

**Tally: 1 MAJOR · 1 MINOR · 4 NIT.** The MAJOR is a repair-coverage gap in an adversarial corner (availability of
the protection acts, never content), honest about its narrow reachability, with a concrete red-on-old pin; nothing
found touches the thirteen promises' content guarantees, and the go/no-go's four mechanical gates (the soak, the
fixed scenarios, the pins, both configurations) stand as recorded.
