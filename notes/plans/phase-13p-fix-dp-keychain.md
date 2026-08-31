# Phase 13p-fix — the macOS data-protection keychain asymmetry

**STATUS: OPEN — opened 2026-08-30 by the author's word, minutes after
the 13p signing gap closed and unmasked this.** Her instruction,
verbatim: *"go ahead and fix it now. however, let's do /architect-phase
and call this a 13p-fix or something like that - if the change isn't
complex, do an Opus cold review at the end, ensure the work goes into
the appropriate plan files, follow normal phase discipline. Even when
fixes are found off the cuff it's important that they're recorded and
handled."*

---

## KICKOFF (self-contained — a fresh session starts here)

**Read first:** this file in full, `CLAUDE.md`, and the FINDING below.
The parent phase's record is `notes/plans/phase-13p-note-protection.md`
(its POST-CLOSEOUT section carries the signing change this phase
follows). Nothing in `Sources/VariorumCore/Sync/` is touched, so the
standing Fable rider does not apply.

**The one-sentence goal:** on macOS an ACL'd or synchronizable keychain
write lands in the DATA-PROTECTION keychain while every read in this
codebase searches the FILE-BASED one — make the three DP-resident item
families read, write, and delete in the SAME keychain.

**Do first:** read the FINDING's measurement; it is the whole design.

**Verify:** the behavioural pin (a gated write through production code
must be findable by production's own probe) fails on the pre-fix tree
and passes after; the Mac suite holds at its count.

---

## THE FINDING (traced and MEASURED, 2026-08-30 — this is the design)

**Mechanism.** On macOS, `SecItemAdd` carrying `kSecAttrAccessControl`
(a biometry ACL) or `kSecAttrSynchronizable` is routed to the
**data-protection keychain**; a `SecItemCopyMatching` that does NOT
pass `kSecUseDataProtectionKeychain: true` searches the **file-based**
keychain. `kSecUseDataProtectionKeychain` appears **nowhere** in this
codebase. So the gated and escrow items write to one keychain and are
read from another.

**Measured in the signed test host** (throwaway service, attributes
only, non-interactive — never prompts):

```
ADD  (production shape: ACL, no DP flag):            0       success
READ without DP flag (= gatedItemExists()'s shape): -25300   errSecItemNotFound
READ with    DP flag:                               -25308   errSecInteractionNotAllowed
```

The item is THERE; production simply looks in the other keychain.

**Why it was invisible until today.** Before the 13p signing gap
closed, every ACL'd write failed at `errSecMissingEntitlement`
(-34018), so the gated paths never once executed successfully on the
Mac and the asymmetry could not bite. The signing change did not break
anything that worked — it unmasked a latent defect that had never been
reachable. **iOS is unaffected**: it has only the data-protection
keychain, so reads and writes agree there. This is macOS-only.

**The consequence class, and it is data-access-shaped.** Both gated
paths delete their plain copy immediately after a "successful" gated
write:

- `DeviceKeyStore.setBiometricGate(true, …)` → `saveGated` succeeds →
  `deletePlainItem()` → on the next read `gatedItemExists()` is false
  and the plain item is gone ⇒ **the device silently de-enrolls from
  E2EE** and sync refuses until a passphrase re-enrollment.
- The 13p at-open Biometric mode → `StoreKeyGuard.saveGated` succeeds →
  `StoreKeyCustody.deviceKeychainRemove(scope:)` deletes the Auto item
  (*"a gate whose key still releases silently is theater"*) ⇒ **no
  Keychain road opens the store**; only the passphrase or recovery
  phrase does.
- ~~`saveEscrow` (synchronizable) vs `loadEscrow` — same asymmetry: the
  escrow copy can never be read back.~~ **WRONG, and corrected at ladder
  round 1 (R1-4).** The escrow family was NEVER asymmetric:
  `kSecAttrSynchronizable` on its own already targets the
  data-protection keychain (TN3137), and `escrowQuery` — the single
  builder for load/save/delete — has carried it since 13p Batch 2, so
  both sides always agreed. Corroborating in-repo evidence the original
  diagnosis walked past: 13p's record has escrow failing at `-34018` (a
  file-based write would not), and `reconcileEscrowOffMain` already does
  read-back-then-write, which would have re-saved on every launch
  forever had the read been blind. The partition marker rides
  `escrowQuery` anyway as a belt, not a fix. **The two GATED families
  are the whole defect.**

**THE AUTHOR HIT BOTH, IN HER OWN HANDS, 2026-08-30**, and her report
is the confirming trace (verbatim): *"i tried opening variorum and the
touchid didn't work, even though i enrolled it, and then i entered my
passphrase, and then i had to enter it again to get sync to start
working."* Keychain state confirmed it exactly: `store-key/Variorum`
**gone** (only `Variorum-dev` left) and `e2ee-keys` **gone**, the
latter restored by her passphrase re-enrollment. No data was lost —
both secrets were verified before the signing change, and the
passphrase road is designed as exactly this fallback.

**Verification-gap note, recorded because it is the lesson.** The
signing work proved the ACL'd write LANDS (`SecItemAdd ==
errSecSuccess`) and stopped there. A feature that writes to one
keychain and reads from another passes a write-only proof and is still
broken. **Rule taken from it: a custody pin asserts the ROUND TRIP —
write, then find it through the production read path — never the write
alone.**

---

## THE FIX (design, settled by the measurement)

Exactly **three** query builders own every DP-resident site (made `internal` at R1-3 so the structural pin can read them)
(verified by grep; no other `kSecAttrAccessControl` /
`kSecAttrSynchronizable` sites exist in production code):

| builder | family | callers |
|---|---|---|
| `EncryptionKeychain.swift:397` `gatedBaseQuery()` | 14b CF-12 gated device keys | clear · deleteGatedItem · gatedItemExists · saveGated · unlockGatedItem |
| `StoreKeyGuard.swift:234` `gatedQuery(scope:)` | 13p Biometric-mode store key | gatedItemExists · saveGated · deleteGated · unlockGated |
| `StoreKeyGuard.swift:280` `escrowQuery(storeID:)` | 13p iCloud escrow | loadEscrow · saveEscrow(+update) · deleteEscrow |

Each family funnels through ONE builder, so the flag lands in three
places and every add/read/delete/probe inherits it.

**What must NOT move.** The PLAIN items stay file-based: the store key
(`store-key/<scope>`), E2EE custody (`e2ee-keys/device-keys`), and the
auth tokens. They exist today in the file-based keychain; flagging them
would strand real data — including the key to her library.

**Orphan sweep, not migration code.** Her Mac carries gated items
written during today's broken window; once reads find them,
`isBiometricGateOn()` would read TRUE against stale material. That
state existed only on one machine for ~3 hours, so it is swept as an
environment act and recorded — shipping permanent migration code for a
state no other install can have would be cruft.

---

## LEDGER

| # | item | status |
|---|---|---|
| 1 | The DP flag on the three query builders | **DONE** |
| 2 | Behavioural round-trip pin (red-on-old, revert-verified) | **DONE** |
| 3 | `Phase13pKeychainFactTests.deleteProbe` cannot delete what it creates (same asymmetry — it left ACL'd litter on every run) | **DONE** |
| 4 | Sweep the author's orphaned gated items | **REFRAMED — see the batch record; impossible from tests BY DESIGN, and that is the right answer** |
| 5 | Opus cold review (her instruction), ladder per CLAUDE.md | in flight |
| 6 | Closeout: master plan row + pointer + closeout paragraph; KnownIssues; QUESTIONS; handoff | pending |
| 7 | `CanvasDragTrackingTests.theResizeGripFollowsThePointerToo` is LOAD-FLAKY (found by this phase's full run; not caused by it) | **recorded — KnownIssues row, owner 12** |

---

## CAST — and one recorded deviation

**Reviewer: OPUS, fresh, cold** — the author's explicit instruction.
Ladder per CLAUDE.md (fresh reviewer per round, `REVIEW_PROMPT.md`
verbatim, zero framing).

**DEVIATION, recorded with reasons per this skill's rule:** the batch
is implemented by the ARCHITECT rather than a fresh implementer
session. Grounds: the diff is three lines of query construction plus
pins; the mechanism was traced and MEASURED by the architect in-session
with a probe whose output is quoted above; a self-contained implementer
brief would necessarily be longer than the change it describes, and
re-deriving a measured platform fact through a briefing seam is where
this class of bug hides. The isolation that carries quality here is the
COLD REVIEW, which is preserved in full and strengthened to Opus at the
author's word. Recorded rather than silent, exactly as the mandate
requires.

**No `Sources/VariorumCore/Sync/` lines.** No schema, no SyncSpec §12
lockstep event; the marker stays 7.

---

## BINDING PRINCIPLES (the 13b constitution, copied verbatim as this skill requires)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks, the board/view-model invariant soak, the
  registry walk (P-1), the per-batch scripted screenshot walkthrough.
  Red-on-old stays absolute: no bug-class fix without a pin that fails on
  the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**P-7 is this phase's spine**, and the verification-gap note above
sharpens it: the pin must be a ROUND TRIP.

---

## ENVIRONMENT TRAPS (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the test host matches mid-run); treat real-store
instances by STORE, not path — NEVER quit or kill one; no Release
builds or `/Applications` refreshes while one lives. Mac tests run from
`App/Variorum/`, suite-level `-only-testing` only, and the "Test run
with N tests" line is the confirmation. NEVER add a custom build
configuration (anything not named exactly "Debug" builds SPM deps
RELEASE and strips VariorumCore's DEBUG-gated oracles). Backups are
WAL-safe with UTC names, ALWAYS before touching the real store (the A1
rail). Never `git checkout` over uncommitted work.

**⚠️ A REVERT THAT REMOVES AN INJECTED SEAM IS NEVER A VALID DRILL
(13p-fix ladder R3-1 — learned the expensive way, in this phase).**
Reverting `setBiometricGate` to its pre-fix body left
`keychain(custody:)`'s parameter UNUSED, so the "fake-driven" pins fell
straight through to the real `E2EEKeychainStorage` at its FIXED account
and overwrote the author's live E2EE custody with test material. Revert
the OUTCOME CHECK, never the seam: `if on { _ = custody.setGated(...);
… return .done }` reddens the same pins with zero Keychain traffic.

**This phase's own trap:** every keychain-touching test MUST use a
throwaway service or a throwaway scope. `StoreKeyGuard`'s gated item
takes a `scope:` parameter and is safely testable;
`E2EEKeychainStorage`'s gated item has a FIXED account
(`device-keys-biometric`) and therefore **must never be exercised
against the real Keychain from a test** — it would write over the
author's live custody. Pins for that family go through the shared
query shape, never the fixed-account door.


---

## BATCH RECORD — the one batch (architect-implemented, 2026-08-30)

**The change, whole:** `kSecUseDataProtectionKeychain: true` added to the
three private query builders that own every DP-resident site
(`EncryptionKeychain.gatedBaseQuery`, `StoreKeyGuard.gatedQuery`,
`StoreKeyGuard.escrowQuery`), each carrying the measurement in a comment
so the reason cannot be lost. Every add / read / delete / probe in those
families funnels through its builder, so they can no longer disagree.
The PLAIN items were deliberately left file-based.

**Ledger 2 — the pin, and the discipline it enforces.** Two tests join
`Phase13pKeychainFactTests`:

- `anACLdAddIsInvisibleToAReadThatDoesNotAskForTheDataProtectionKeychain`
  pins the PLATFORM FACT (add 0 · read-without -25300 · read-with
  -25308) so the reason for the flag survives its author.
- `theGatedStoreKeyIsFoundByProductionsOwnProbeAfterProductionWritesIt`
  is the RED-ON-OLD pin — a ROUND TRIP through production code:
  `StoreKeyGuardKeychain.saveGated` then
  `StoreKeyGuardKeychain.gatedItemExists`.

**Behavioural revert performed, not asserted:** the flag was stripped
from all three builders (a copy-aside restore, never `git checkout` over
uncommitted work), the suite run, and the round-trip pin FAILED at
`gatedItemExists` — with the platform-fact pin still passing, which is
correct: it is a fact about the platform, true on both trees. The fix was
restored and all five pass. Safety by construction: the pin uses a
throwaway `scope:` and a ThisDeviceOnly item, so it never touches real
custody and never writes a synchronizable byte into her iCloud Keychain.

**Deliberately NOT pinned behaviourally, with the reason:** the ESCROW
family. Its item is `kSecAttrSynchronizable`, so any real round-trip pin
would push test bytes into the author's iCloud Keychain — the 13p suite's
own standing prohibition. Its fix rides the same one-builder funnel as
the pinned family. The E2EE gated family is likewise unpinned at its own
door: its account is FIXED (`device-keys-biometric`), so a test write
would land on her live custody. Recorded as an accepted, reasoned gap
rather than papered over.

**Ledger 4 — the orphan sweep, REFRAMED by a finding.** The intent was to
sweep the gated items the broken window left on her Mac. It cannot be
done from a test, and the reason is the dev fence working exactly as
designed: **the data-protection keychain partitions by ACCESS GROUP**,
*[removed for publication]*
*[removed for publication]*
inventory returned empty from the test host for that reason alone — it is
structurally blind to them, which is precisely the isolation the
per-config group was chosen for at the signing change.

*Consequence for the author — CORRECTED at ladder round 1 (R1-5), which
caught this paragraph asserting as fact what the same page had just
proved unobservable.* Stated properly, as an expectation to VERIFY:

- **Predicted, not observed.** From the incident's own sequence her Mac
  should now hold BOTH a gated E2EE item (her toggle wrote it and
  deleted the plain one) AND a plain one (her passphrase re-enrollment
  hit `save:`, whose `gatedItemExists()` read false through the broken
  read, so it wrote plain). Nothing in this session could see either —
  the test host is in a different access group.
- **If that holds, the state is the one the custody law forbids.**
  Post-fix, `load:` short-circuits on `gatedItemExists()` and
  `isBiometricGateOn()` reads TRUE — while an ungated copy of the same
  material sits in the file-based keychain, readable with no Touch ID,
  under a UI claiming custody is gated. That is exactly *"a gate whose
  key still releases silently is theater"* (`StoreKeyGuard.swift`).
- **The clean-up is TWO steps, and round 2 caught the first draft of
  this sentence prescribing an act that refuses (R2-9).** Post-fix the
  orphan gated item becomes findable, so `DeviceKeyStore.load` returns
  nil (locked, not absent) and the toggle's own door opens with
  `guard let material = store.load() else { return .noMaterial }` —
  i.e. *"Unlock this device's keys first."* So: **(1) UNLOCK** — Touch
  ID, or the passphrase road; the surface lands in `.enrolledLocked`,
  which offers both — **(2) then toggle the sync biometric requirement
  OFF.** Both arms now delete the other half through `CustodyHandover`,
  so that resolves the coexistence AND exercises the fix. *Named branch:
  if the orphan is biometry-invalidated, the passphrase road re-adopts
  through `save:`, which sees a gated item and keeps the gate ON — so
  the toggle-off must come AFTER the unlock, not be replaced by
  re-enrollment.* *(An earlier draft of this paragraph said the gated item "holds
  real material" while the FIX section above called it stale — the
  contradiction is resolved here: its content is almost certainly the
  same key material, and it is the COEXISTENCE, not the content, that
  is wrong.)*

Shipping migration code for a state that existed on one machine for
three hours would still be cruft; the door is the road.

**Ledger 7 — a flake found, not caused.** The full run failed
`CanvasDragTrackingTests.theResizeGripFollowsThePointerToo` (mid-drag
read `(24,16)` of a `(60,40)` pointer drag). This phase's diff is three
lines of keychain query construction and cannot reach canvas geometry.
Isolated re-runs: **3/3 green**. It is a pointer-drag simulation whose
verdict depends on machine load — the same family as the standing
latency-pin row, and it gets its own KnownIssues row at owner 12 rather
than being waved off as "probably fine".

**Counts (corrected at round 2 — R2-8 caught them stale):** the round-1
figure `1845/312` was true at commit `48d047d` and was never updated when
`3779e77` added three more tests and a suite. Baseline `1843/312`; this
phase adds **8 tests and 2 suites** across both rounds — `+2`
`Phase13pKeychainFactTests`, `+1` `Phase13pControllerTests`, `+2`
`KeychainPartitionTests` (new suite), `+5`… **MEASURED FINAL: Mac
1853 tests / 314 suites**, green but for the known `CanvasDragTrackingTests`
load flake (3/3 green isolated, both runs, both tests — its KnownIssues row
at owner 12 now covers the suite rather than one assertion). Arithmetic
checks: 1843 + 10 = 1853 and 312 + 2 = 314, where the 10 are +2
`Phase13pKeychainFactTests`, +1 `Phase13pControllerTests`, +2
`KeychainPartitionTests` (new), +5 `CustodyHandoverTests` (new). **No `Sources/VariorumCore/Sync/` lines.
No schema. No lockstep — marker stays 7.**


---

## LADDER — ROUND 1 (fresh Opus cold reviewer, `REVIEW_PROMPT.md` verbatim, zero framing)

14 findings: 5 MAJOR · 4 MINOR · 4 NIT. **Zero disputes** — every
finding was traced by the architect before disposition, and the two that
correct this phase's OWN record (R1-4, R1-5) were accepted as written.

| # | sev | disposition |
|---|---|---|
| R1-1 | MAJOR | **FIXED.** The phase fixed the CAUSE and left the FAILURE MODE: both custody transitions still deleted the surviving plain item on a write's success alone. Now both go through the new `CustodyHandover` rule — write, VERIFY it reads back through the production read path, only then delete — with a best-effort roll-back of an unreadable write. **Red-on-old proven by behavioural revert:** with the guard removed, the new pin fails all three assertions and `backing.auto → nil` — the incident reproduced in a test. Reviewer's own proposed pin shape (an "invisible gated write" knob on the in-memory backing) adopted verbatim. |
| R1-2 | MAJOR | **ACCEPTED; comments corrected, decision escalated.** Apple's `kSecAttrAccessible` reference confirms the plain items' protection class is inert on macOS without the DP flag or synchronizable, so `WhenUnlockedThisDeviceOnly` is not in force and the store key rides Migration Assistant to other hardware. Two production comments asserted otherwise; both fixed. The DECISION (bind the key to the device or not) is the author's — **QUESTIONS #82**, KnownIssues row at owner **13x**. |
| R1-3 | MAJOR | **FIXED, by a different route than proposed — recorded.** The reviewer proposed parameterizing `E2EEKeychainStorage`'s fixed gated account so it could be pinned behaviourally. Rejected in favour of a STRUCTURAL pin (`KeychainPartitionTests`): it needs no restructuring of security-critical account naming, and it covers all THREE families — including escrow, which cannot be pinned behaviourally either (a real round trip would push test bytes into her iCloud Keychain). The three builders became `internal` for exactly this. The stated risk — "nothing fails if `gatedBaseQuery` loses the flag" — is now false. |
| R1-4 | MAJOR | **ACCEPTED — the phase's own diagnosis was WRONG about escrow.** `kSecAttrSynchronizable` already targets the data-protection keychain, so that family was never asymmetric. The FINDING's third bullet is struck through and corrected in place (never deleted — a binding record that quietly loses its errors teaches nothing), and `escrowQuery`'s comment now says what the marker is there: a belt, not a fix. |
| R1-5 | MAJOR | **ACCEPTED — record corrected.** The batch record asserted facts about her live custody two paragraphs after proving the session was structurally blind to them, and contradicted its own "stale material" wording. Restated as predictions to verify, with the theater state named and the one-act clean-up spelled out. |
| R1-6 | MINOR | **FIXED.** The sibling "nothing landed" probe searched the file-based keychain for the absence of a DP-only item; it now carries the marker. |
| R1-7 | MINOR | **FIXED.** The round-trip pin now asserts its own cleanup — a delete must reach the keychain the write reached, the third leg of the same round trip. |
| R1-8 | MINOR | **FIXED.** The triplicated 12-line comment (including a plain-items sentence that was nonsense inside `escrowQuery`) is gone; the decision has ONE name, `KeychainPartition.dataProtection`, with the measurement stated once beside it, and the three builders merge it. This is also what gives R1-3's pin something enumerable to assert. |
| R1-9 | MINOR | **ACCEPTED — owed at closeout.** Both edited `Shared/` files ship in `VariorumMobile`. The parity line will read *mobile-visible as a documented no-op*, with Apple's citation that other platforms behave as if the key were set and ignore it. |
| R1-10 | MINOR | **ACCEPTED — and it outranks the phase.** See the GOVERNANCE section below. |
| R1-11 | NIT | **FIXED** — suite renamed to what it now pins. |
| R1-12 | NIT | **ACCEPTED, not reversible.** `48d047d` swept in `notes/ProactiveTechDebtReview-2026-08-30.md` (1,385 lines) — a CONCURRENT session's artifact, captured by `git add -A`. History rewrites are author-only, so the commit stands and this row is the record. Lesson taken: explicit paths, never `-A`, in a shared tree. |
| R1-13 | NIT | **NOT THIS PHASE'S.** The stale line lives in that concurrent session's own in-flight artifact; editing another session's working file is how work gets lost. Raised to the author instead. |
| R1-14 | NIT | **ACCEPTED — KnownIssues row at owner 13r.** A Developer ID build must carry the same `keychain-access-groups` or every gated item and escrow copy is unreachable for users; the new `CustodyHandover` guard turns that from a lockout into a visible refusal, but the profile still has to carry the group for the feature to exist.

**Clean bill accepted as written** — notably its independent
confirmation that the site enumeration is complete, that the change
cannot strand existing data, and that no test touches the fixed-account
E2EE door.

---

## GOVERNANCE — R1-10, and why it stops here

The reviewer noticed an **uncommitted `CLAUDE.md` amendment in the
working tree**, dated today, recording an author ruling: bug fixes and
tech debt do NOT go in the master plan — they become lettered entries
(**17a, 17b, 17c…**) in `notes/plans/phase-17-standing-fixes.md`, which
never closes; `DetailedPlanForPhases.md` is **product advancement
only**; and a 17-entry is a valid KnownIssues owner.

**This phase is a bug fix.** Under that ruling its closeout belongs in
the Phase 17 file as a lettered entry, NOT as a master-plan row — which
is what ledger 6 currently plans.

**It is not resolved autonomously, for a reason that is not
squeamishness:** `notes/plans/phase-17-standing-fixes.md` is UNCOMMITTED
and belongs to a session that is *still live in this tree* (its files
moved during this phase's run). Two sessions writing one file is how
work is lost, and this phase already learned that lesson the cheap way
by sweeping that session's artifact into a commit (R1-12). **The author's
sequencing call is the input this closeout waits on.**


---

## LADDER — ROUND 2 (fresh Opus cold reviewer; anchor = the round-1 record)

14 findings: **1 MAJOR** · 9 MINOR · 4 NIT. Zero disputes. The MAJOR is a
NEW finding, so **round 3 is owed** under CLAUDE.md's ladder.

| # | sev | disposition |
|---|---|---|
| R2-1 | MAJOR | **FIXED — and the finding is exactly right.** Round 1's behavioural revert proved the STORE-KEY guard and the record said "both … proven". It did not prove the E2EE guard, which no test could reach: `DeviceKeyStore.inMemory` maps `setBiometricGate` straight to its backing, and only `keychain()`'s closure ran the rule, so deleting BOTH `CustodyHandover` calls left the whole suite green. **That untested half is the one that bit the author** — `e2ee-keys` is the item that went missing. Fixed by the reviewer's own proposal (2): a small `E2EECustodyStorage` seam (`DeviceKeyStore.keychain(custody:)`), defaulting to live, with account naming untouched so R1-3's rejection still stands. Now pinned twice — three direct unit tests of `CustodyHandover.perform`'s outcomes, and two E2EE transition pins driven by a fake. **Red-on-old proven by behavioural revert of the E2EE half specifically:** restore the pre-fix two-liner and both E2EE pins fail. |
| R2-2 | MINOR | **FIXED.** `perform` returns a typed `Outcome`; the `wroteButUnreadable` arm no longer claims "nothing was altered" (it was false in exactly the case the guard exists to surface) and instead names the keychain-identity symptom with the road back. |
| R2-3 | MINOR | **FIXED.** The gate-OFF and `.auto` arms gained the `rollBackIncoming` their twins had; without it a failed verify left a readable ungated copy beside a live gate — theater arrived at through the OFF door. |
| R2-4 | MINOR | **FIXED.** The plain arms verify IDENTITY (`== key` / `== material`) rather than presence, so a stale orphan under the same service/account cannot satisfy the guard. The gated arms stay presence-only — reading an ACL'd item's data prompts, and a write must never prompt — and `CustodyHandover`'s doc now states that exception instead of leaving the weaker check reading as uniform policy. |
| R2-5 | MINOR | **FIXED.** The platform-fact pin asserted `== errSecInteractionNotAllowed` where production itself accepts either that or `errSecSuccess`; it now asserts `!= errSecItemNotFound` (the discriminating fact), with today's measured -25308 kept in the comment. Avoids reding for a non-regression on a point release. |
| R2-6 | MINOR | **FIXED.** `InMemoryStoreKeyGuardBacking.saveAuto` mutated before returning the failure verdict — a Keychain that reports a failed write never also changed the item. Guards first now, like its siblings. |
| R2-7 | MINOR | **OWNED, not fixed — 17a.** `saveGated`'s delete-then-add window is pre-existing since 14b and is FORCED (updating an ACL'd item prompts). Recorded with its mechanism, its mitigation, and a remedy sketch on a KnownIssues row at **17a**, whose own title is this exact subsystem. |
| R2-8 | MINOR | **FIXED.** The counts were stale by 3 tests and a suite; corrected and re-measured. |
| R2-9 | MINOR | **FIXED, and it mattered.** The prescribed clean-up (*"toggle the requirement OFF"*) would have REFUSED with "Unlock this device's keys first", because post-fix the findable orphan makes `load` return nil. Restated as two steps with the invalidated-biometry branch named. |
| R2-10 | MINOR | **FIXED.** 13p's POST-CLOSEOUT and the author handoff — the two documents actually read — still presented the write-only proof as the conclusion, and neither mentioned this phase. Both now carry a dated correction; the handoff's item 2 says plainly that custody was lost hours later and recovered. |
| R2-NITs | NIT | **ALL FIXED** — the mangled `).///` doc comment, the run-on line, the stale "-34018" comment three tests above a pin that now asserts success, and the partition test's doc, which now claims only what it guards (three families by hand, drift not omission). |

**Clean bill accepted as written**, including its independent
re-verification of the site enumeration, the no-stranding argument, and
the R1-4 escrow correction — plus one useful new fact: the previously
unreachable DP orphans are now not just readable but **deletable**
(`E2EEKeychainStorage.clear()`'s gated leg could never fire before).


---

## LADDER — ROUND 3 (fresh Opus cold reviewer; the FINAL round — CLAUDE.md caps it at three)

3 MAJOR · 5 MINOR · 6 NIT. Zero disputes. Per the cap, what is not fixed
here is RECORDED WITH AN OWNER and not looped on.

| # | sev | disposition |
|---|---|---|
| R3-1 | MAJOR | **CONFIRMED, AND IT HAPPENED — the worst finding of the phase, against the phase itself.** The round-2 revert drill removed the seam's USE, so `keychain(custody:)`'s parameter went unused and the fake-driven E2EE pins fell through to the real `E2EEKeychainStorage` at its FIXED account — violating the ENVIRONMENT TRAP this very plan states. Verified from the live Keychain: `e2ee-keys/device-keys` has `cdat == mdat == 2026-08-30 18:04:31`, inside the drill window, and a read of its key IDENTIFIERS (never its bytes) returned `corpusKeyID=corpus`, `journalBridgeKeyID=bridge`, `masterKey` = 32 zero bytes — **the drill's sentinel**. So the author's E2EE device custody was overwritten by a test. Consequence: sync refuses until she re-enrolls with her passphrase (the designed road, no data at risk — the vault is server-side). **Attempted cleanup was correctly BLOCKED** by the permission classifier: deleting a Keychain item via the test runner is a non-test action, and routing around it would have been the wrong move. Left to the author with both roads written up. Record fixed: the drill recipe is corrected and the ENVIRONMENT TRAPS section now carries the rule in bold. |
| R3-2 | MAJOR | **FIXED, with a red-on-old pin.** R2-2's honesty fix reached only the store-key surface; `DeviceKeyStore.setBiometricGate` collapsed both failure arms into `Bool`, so the E2EE surface still said *"nothing was altered"* in the case R2-2 itself called a lie — on the family whose item actually went missing. The seam now carries `CustodyHandover.Outcome` end to end, `BiometricGateOutcome` gained the case, and the sentence moved to `ProtectionCopy` (nonisolated) so BOTH surfaces speak it. Drill run on the outcome mapping only — never the seam. |
| R3-3 | MAJOR | **FIXED.** The GOVERNANCE section was stale: the CLAUDE.md amendment and the standing-fixes file were committed at `44693db`, 16 minutes before this phase's own round-2 commit, and `phase-17-standing-fixes.md` already RESERVED **17g** for this work. The author confirmed it directly. Ledger 6 is rewritten: the closeout is a 17g entry, no master-plan row, no master-plan closeout paragraph. |
| R3-4 | MINOR | **RECORDED, owner 17a.** `E2EECustodyStorage.live`'s wiring is covered by nothing — transpose `deleteOutgoing`/`rollBackIncoming` and the suite stays green while the incident reinstates. A behavioural pin needs a further seam change; the reviewer labelled that honestly and so does this row. |
| R3-5 | MINOR | **RECORDED, owner 17a.** The custody law is enforced on writes only: every delete discards its `OSStatus`, so a silently-failing delete produces the theater the codebase forbids — and a silently-failing delete in this exact family is *demonstrated*, not hypothetical (pre-fix `deleteGated` searched the wrong keychain for three hours). Remedy sketch and a `deletesSucceed` knob are named on the row. |
| R3-6 | MINOR | **RECORDED, owner 17a.** `setMode` runs two-to-three synchronous `SecItem*` calls on the MainActor and this phase added one of them, against 13e batch 9's discipline — while the E2EE twin already rides `offMain`. User-initiated cadence, not per-round. |
| R3-7 | MINOR | **FIXED (record) + RECORDED (test gap, owner 13x).** One of R1-4's two corroborations cannot have been observed and is struck through; TN3137 plus the -34018 inference carry it alone. The escrow family's live round trip is verified by nothing anywhere — a recovery leg 13x's adoption road is built on — so it gets a KnownIssues row rather than living only in a plan file that closes. |
| R3-8 | MINOR | **FIXED.** The "Consequence for the author" enumeration covered only the E2EE half and omitted the store-key half she actually experienced; corrected, including the traced consequence that post-fix her Biometric-mode launch will now SUCCEED and the missing Auto item stays missing *by design* under a demanded mode. |
| R3-9 | MINOR | **FIXED at closeout.** R1-9's promised parity wording was inaccurate: only the DP marker is a no-op on iOS — `CustodyHandover` is a genuine behavioural change shipping in `VariorumMobile`. MobileSoul gets a real row, not a no-op line. |
| R3-NITs | NIT | Run-on line **FIXED**; the pin message that claimed a property it cannot observe **FIXED**; the `E2EELaunchKeyCache` global write **RECORDED** on 17a's row; the FIX table's stale "private" **FIXED**; the KnownIssues header's owner wording **FIXED** to include 17-entries; the `wroteButUnreadable` copy **re-worded** (it asserted one cause as "usually" and prescribed an action a user can't take) and flagged for 13s's voice pass. |

**Clean bill accepted**, including its independent full-suite run at
`9b1669c` — 1853/314 fully green, canvas flake included — which
corroborates this phase's own measurement.


---

## CLOSE — the owed verification and the install (2026-08-30, at her word)

**The verification gap is CLOSED.** Round 3's changes had only targeted
suites green when the record was written, and the full run was
interrupted three times as a background task (foreground runs completed
without trouble both times — recorded as an environment note, not a
finding). Measured in the foreground on the final tree:

**Mac 1854 tests / 314 suites — ALL PASSED**, `CanvasDragTrackingTests`
included. That is 1853 + the R3-2 pin; suites unchanged. Against the
1843/312 baseline the phase adds **+11 tests, +2 suites**, every one
named in the ladder records.

**`/Applications` refreshed** behind the A1 rail: zero instances and the
real store `lsof`-verified closed, a fresh ciphertext backup taken first
(`pre-13pfix-install-backup-20260831T010328Z`, sha256-matched), installed
binary hash-matched to the build product, `keychain-access-groups =
*[removed for publication]*
`wroteButUnreadable` copy confirmed present in the shipped binary. **Her
daily-drive build now carries the fix**, so the E2EE re-enrollment she
owes lands on the guarded build rather than needing to be done twice.

**Still hers, and only these:** delete the drill's `e2ee-keys` item and
re-enroll with her passphrase (R3-1); the two-step biometric clean-up if
that orphan is still present; QUESTIONS **#82**.
