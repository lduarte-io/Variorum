# VM-8 — ladder round 2 (cold review, Opus — re-review of round 1's fixes)

**Reviewer:** a fresh Opus cold reviewer running `notes/REVIEW_PROMPT.md` verbatim. **Charter (from the orchestrator's
brief):** re-review round 1's fixes (L1): are they sound, complete against their dispositions and honestly pinned? Also
judge L1's MINOR-1 reading. **Diff:** `git diff 2243a26aa..HEAD` on `vm-8-protection-recovery-faces` (tip `5df6682c5`);
I read every hunk. **Anchor:** `notes/plans/vm-8-ladder-round1.md` (the findings, the dispositions, the orchestrator's note
on L1's reading) and `notes/plans/vm-8-castle-catchup.md` (UNIT 2 — LIVE STATUS ▸ L1; P-VM8-8, -9 and -10; ENVIRONMENT
TRAPS). The context for the MINOR-1 judgment is CastleRules rules 10, 12 and 15, SurfaceContracts' protection bullet, and
R-529-3 as asked and ruled (`notes/plans/fixes/vx-529-pair-catchup.md`, RULING 4).

**Scope check (first):** L1 touches:
- no `Sources/` line, so nothing under `Sources/VariorumCore/Sync/`;
- no editor seam;
- no custody or keychain code;
- no default's meaning.

The twelve `Shared/` files it changes are comment-only. I filtered every `+` and `-` line of
`git diff 2243a26aa..HEAD -- App/Variorum/Shared/` for `//` and `///`, and nothing else is left. The production changes are
in three phone files: `MobileProtectionDoors.swift`, `MobileProtectionScreen.swift` and `MobileSettingsView.swift`. No
re-spawn as `fable-reviewer` is owed.

**What I ran.** The stage claim was `vm8-r2`, now released. I used the pinned simulator
*[removed for publication]*
scratchpad, with its own DerivedData. I never touched the worktree and committed nothing but this file.
1. **Build:** `build-for-testing` of the copy gave `** TEST BUILD SUCCEEDED **`.
2. **L1's sixteen suites at the tip** (RUN B's set) gave `✔ Test run with 47 tests in 16 suites passed after 66.011
   seconds.` That matches the record's RUN B exactly.
3. **A scratch probe:** one extra hosted test, in the copy only, never committed. It mounts the real
   `MobileProtectionScreen` over the same hand-made faces L1's pins use and prints what the screen says in four states.
   The output is quoted under the verdict below.
4. **A behavioral-revert spot check.** In the copy, I put `MobileProtectionDoors.swift`, `MobileProtectionScreen.swift` and
   `MobileSettingsView.swift` back to `2243a26aa`, rebuilt, and ran the four suites the pins live in. Result:
   `✘ Test run with 16 tests in 4 suites failed after 23.856 seconds with 17 issues`. These seven pins went RED:
   - MINOR-1's five, with the record's counts: 2 and 2 for the two pair pins, 4 for the generic kind, 4 for the held
     follow out, and 3 for the belt;
   - `aLockedDoorKeepsItsRowUnlessTheFollowLocksIt`;
   - NIT-2's `noServicesNoProtectionRow` and `settingsOpensTheScreenOnlyWhereItCanAct`.

   The nine other tests stayed green. This reproduces RUN C's RV-L1-3 and RV-L1-4 independently.

## Findings (severity-ranked)

**0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT.** No round 3 is earned.

### MINOR-1 (r2) · `MobileProtectionDoors.swift:441-447` vs `:281-282` · the follow-locked screen leaves the words section empty under its lead while the passphrase section vanishes

**What's wrong.** L1's rule is that a section renders nothing for a door the follow locks. The two key-door sections apply
it differently.

- **The passphrase section** draws its heading only when it has a row: `if standing.offersSetPassphrase || !rows.isEmpty`
  (`:282`). L1's rows are `[]` for a follow lock (`:266` for the pair gate, `:272` for the generic sentence), so the whole
  section disappears, "Your passphrase" heading included.
- **The words section** draws its heading and its lead unconditionally (`:441-442`). Then it renders `EmptyView()` for the
  follow-locked door (`:445-447`).

On the phone, the "Your twelve words" heading therefore stands over its lead, "…looking makes new ones for you to write
down…". That sentence explains an act the section no longer offers, and nothing there says why. The why is the one
saying, which sits several sections down in the Sync section's follow place.

**Evidence: the probe, the real screen.**
- **State A (keys replaced elsewhere, Castle):** `Protection || Your twelve words || Variorum doesn't keep your twelve
  words, so looking makes new ones for you to write down. Your library's key doesn't change. || You're in Castle. || …`.
  There is no "Your passphrase" heading, and no door under the words lead.
- **States B (the pair) and C (the held follow out):** the same shape.
- **State D (nothing owed), for contrast:** `Your passphrase || Change passphrase… || Reset forgotten passphrase… || Your
  twelve words || <lead> || Record your twelve words… || <VX-263's line>`.

L1's own pin asserts the empty lead: `MobileProtectionDoorsTests.swift:661-662`, "the sections keep their own lines",
`labels.contains(ProtectionWords.wordsSectionLine)`. Nothing acts wrongly; this is a clarity issue on the small screen.

**Pin (red at the tip, green after the fix).** Use the probe's state A, which is `anOwedFollowSaysItsRefusalOncePerScreen`'s
own faces. While New words is follow-locked, expect `!labels.contains(ProtectionWords.wordsSectionTitle)` and
`!labels.contains(ProtectionWords.wordsSectionLine)`. Flip `:662`, and keep the posture-line expectation at `:661`.

**Proposed fix: one rule for both key-door sections, no new words.** A key-door section whose every door the follow locks
renders nothing, heading and lead included. `MobileWordsSection` would then go whole in the follow-locked arm, as
`MobilePassphraseSection` already does. The crossings' posture line stays, because it states the posture rather than
introducing a door. If the orchestrator would rather not build this tonight, the alternative is to name the empty words
section in her bundle beside P-VM8-9's shape question, so she rules on the whole follow-owed screen: the passphrase
section gone, the words lead with nothing under it, the posture line alone (unit 2's flag (d)), and the one saying.

### NIT-1 (r2) · `MobileProtectionScreen.swift:188-194` + `MobileProtectionDoors.swift:226` · the follow's place says the change twice

Where the follow door renders, its notice and the one saying stand next to each other. The second sentence says less than
the first:
- **Probe B:** `Your account's passphrase was changed on Studio Mac. || Your account changed on another device. Follow it
  first. || Follow your account…`
- **Probe A:** `Your account's keys changed on Studio Mac. || Your account changed on another device. Follow it first.`

The shared words already hold R-529-3's own shape for this spot. `followFirstToCatchUp` is the notice plus
`followFirstToCatchUpRoad`, "Follow your account to catch this iPhone up first." That pairing is the Mac's key-door refusal.

**Proposed: a bundle line beside P-VM8-9 (the words are hers), not a fix tonight.**
- Where the follow door renders, the road could follow the notice, so the follow's place reads as the Mac's R-529-3
  sentence, once.
- Where no door renders (P-VM8-10), the generic sentence stays the one truth-teller.

This would change the disposition's "4 → 1 generic" count to 0 where the door renders, so it is the orchestrator's
arbitration. There is no pin, because this is wording.

### NIT-2 (r2) · two trued comments over-reach (comments only)

- **`MobileProtectionDoors.swift:27-29`** ends "…the newest few said (up to three, one line each), never a single line."
  A screen that has heard one receipt shows exactly one line (`MobileProtectionReceipts.say` keeps one to three). The
  intended meaning is "never merged into one line"; say that, or drop the clause.
- **`MobileProtectionScreen.swift:19-20`** says "meanwhile the follow-owed state is P-VM8-10's recorded dead end". P-VM8-10's
  dead end is narrower: it is the follow OUT of Castle owed, plus Move out of Castle with another account signed in. The
  into-Castle, key-replacement and pair follows all render their door.

### NIT-3 (r2) · `notes/plans/vm-8-castle-catchup.md:904-907` · the reason the record gives for L1's leftover (a) is incomplete; the hole is closed by timing, not by sign-in

This is the leftover the brief asked me to check: the "Signing in isn't available in this window." sheet during the
re-keying reopen. L1 says *Sign in…* isn't offered there because "the account [is] signed in by then on every re-keying road
walked". Not every re-keying road has an account signed in. A local Use Castle with no one signed in is a re-keying road
that does offer *Sign in…*:
1. `Assess.doors` opens `.useCastle` on a `.localOnly` library whatever the sign-in. Its `signedOut` flag is the
   `.signedOut` situation only, meaning a bound library with no one signed in.
2. That Use Castle re-keys through `reopenAround` (`AppBootstrap.swift:1217`), which asks for Protection back (`:1254`).
3. The re-pushed screen's account section is `.localOnly` with `signIn: !signedIn`, so *Sign in…* renders.

Two things actually close the hole:
- The reopened `.ready` arm's `.task` composes `services` in its first statements, before `start()`
  (`VariorumMobileApp.swift:90-108`). So `services == nil` lasts only from the arm's appearance to that task's first turn,
  which is a frame, inside the push animation.
- While the crossing's confirm still stands, the account doors are disabled (`MobileProtectionScreen.swift:233`,
  `.disabled(model.presenter.sheet != nil)`).

No human press reaches the window. Any test of a one-turn window would be hollow. **Record-only:** correct the record's
sentence; there is no code fix.

### NIT-4 (r2) · the record at the tip · the orchestrator's dispositions are not all in the repo yet

These are outside L1's charter, and L1 named each of them as the orchestrator's:
1. **MINOR-3's tickets exist on Linear** as VM-25 (the phone's idle dial and Lock Library Now) and VM-26 (the keystone line's
   phone home), both created 2026-10-25. No repo file names them; a grep of `notes/` finds neither. Round 1's fix
   line was "the ledger names the owner".
2. **NIT-6's hours-waiting receipt consequence** isn't in her bundle beside P-VM8-8; item 9(a) doesn't name it.
3. **Bundle item 9(b)** still reads unit 2's "(b) P-VM8-9 — the pair sentence once". The PROVISIONALS entry already says
   (a-unified).
4. **The VX-542 note:** I can't verify it from the repo.

**Fix:** fold all four into the record at the next orchestrator commit or at closeout.

## The MINOR-1 reading — VERDICT: **STANDS** (the phone-native shape; not a defect)

The question was whether hiding the key doors whole while a follow is owed reads as a defect on the small screen ("where did
Change passphrase go?"). I find it doesn't, for these reasons:

1. **The door was already off the screen before L1.** Neither platform ever renders a refused key door's label:
   - The Mac's refused row is the sentence alone (`RoadKeyDoorSheet.swift:44-48`).
   - Unit 2's phone rows were the same.

   In the follow-owed state, *Change passphrase…* wasn't on the phone's screen before L1 either; a caption stood in its
   place. L1 moves the sentence, not the door. Probe D against probe A shows it: *Change passphrase…* and *Reset forgotten
   passphrase…* render only when they're open.
2. **What R-529-3's refusal says is kept whole, and said once.** The Mac's pair refusal is `followFirstToCatchUp`, the
   pair's notice plus the road. The phone's follow place says that same notice (the half that changed, the device, the
   day), then the one saying, then the one door that clears the lock (probe B). The ruling's reason, "one road to one
   act", holds: the road is the door itself.
3. **P-2 and her kickoff line are both honored.** No door renders that cannot act. The real refusal is delivered once,
   beside the act that ends it. VX-542's repetition is not copied (4 → 1, and 2 → 1 for the pair, pinned red-on-old and
   reproduced here).
4. **The dead end gets no worse.** P-VM8-10's held follow out says its truth once instead of four times (probe C:
   `… || Sync || This library syncs with your account. || Your account changed on another device. Follow it first. ||
   Delete the account from this iPhone…`).
5. **L1's reading is the coherent one.** The disposition's letter ("locked doors keep their rows; the per-section short
   pointer collapses to the one saying") can't be met together with "once per screen". L1 reconciled it: a door refused for
   any OTHER reason keeps its row (pinned as a guard). That is the reading that keeps both halves.

**What remains is inside the shape, not against it:**
- the empty words section (MINOR-1 r2);
- the double saying in the follow's place (NIT-1 r2).

The taste question her bundle carries is still hers: the Mac meets R-529-3's "Change passphrase refuses" in the door's own
place, and the phone meets it in the follow's place. My call for this ladder is that the built shape stands.

## Clean bill (checked and found solid)

- **Scope.** There are zero `Sources/` lines, and every `Shared/` change is a comment (filtered by diff). The Mac's rendering
  is untouched. `MobileFollowOwed` and every new branch are phone-only.
- **Pins came before the fixes.** `5c5ed06e6` (the pins) is test-only, and its pins compile on the pre-fix production tree:
  they reference only pre-existing API (`rows`, `U2Faces.keyDoors(pairGate:)`) and never `MobileFollowOwed`. The fixes
  `67924b29a` and `bbc4c2c08` come after it.
- **MINOR-1's mechanism is sound.**
  - **At most once.** `followRow` says the one saying at most once. The belt speaks only when the account section has no
    faces, which is exactly when that section renders nothing (`if let faces = model.faces`).
  - **At least once.** Every hiding arm keys on facts `MobileFollowOwed.locks` reads: the passphrase rows and the words
    section key on the pair gate or `.refused(saying)` on a key door; the crossings key on a `phoneDoors` door; the account
    leaves key on `.refused(saying)`.
  - **Stale reads stay safe.** If the key doors are fresh and the account faces stale, `followOwedElsewhere` still says the
    saying once.
  - **No false matches.** The sentence `doorRefusedFollowOwed` is produced for a door face only by `.followOwed`
    (`RoadCrossingFaces.refusalSentence`, `RoadAccountFaces.leaf`), and `Assess` refuses the key doors, the crossings and
    Stop syncing here together (the shared `followOwed` gate). So the lock reads cannot fire on another refusal.
- **MINOR-1's pins assert what the disposition ruled:**
  - once per screen for the generic kind;
  - the pair, both hand-made and end to end through the real derive (`aPairChangedElsewhere…`);
  - the held follow out, at least once and exactly once;
  - the belt;
  - a door refused for another reason keeps its row (a guard).

  They are red on the pre-fix tree (RUN A), red by revert (RUN C, reproduced here) and green at the tip (47/16, reproduced
  here).
- **MINOR-2's E6 line.** `MobileRoadFaces.swift:140` renders it, and `fd56f2279`'s copy has no `accountPassphraseLine`.
  The pin runs through the phone's own bootstrap (a join by the twelve words under Always ask, then a lock), asserts the E6
  precondition on the face, and expects the line under the lead. RV-L1-1's red is that label's absence.
- **NIT-2.**
  - The row and the sync row's door are both gated on `services != nil` (`MobileSettingsView.swift:84`), the sync row's own
    *Starting…* pattern.
  - The dead nil-sentence arm is gone, and that's safe: the host's `switch` over `ProtectionSheetPresenter.Sheet` is
    exhaustive with no `default` (7 cases, 7 arms), so a future case fails to compile instead of falling through.
  - The hosted pin and the source pin are both red by revert (reproduced here).
- **NIT-5's parity guard is not hollow.** All 8 column-zero declarations of `MobilePlantedProtection.swift` are compared,
  each with its doc comment. There are no attribute lines or free functions that would escape comparison (checked). It
  goes red on a one-byte drift (RV-L1-2). Only the header and imports are excluded, by design.
- **NIT-1 and NIT-6 comments.**
  - Round 1's list is covered.
  - The same-class extras (four `Shared` headers and `AppBootstrap.attach`) are comments only.
  - The `herRuleTwelve` exemption is byte-untouched (`MobileStructuralTests.swift` is not in the diff).
  - The receipts code matches its trued comments (newest three, oldest first), apart from NIT-2 (r2).
- **Nothing beyond the charter.** I found no behavior change outside MINOR-1 and NIT-2. The removed `ProtectionOpenRoad.log`
  line went with its dead arm.
- **Bookkeeping holds.**
  - 47/16 = 41/13 + 6 tests in 3 new suites (`MobileProtectionFollowOwedOnceTests` ×3, `MobileLobbyE6LineTests` ×1,
    `MobilePlantedProtectionParityTests` ×1, plus `noServicesNoProtectionRow` in an existing suite).
  - 847/139 = 840/136 + W-U2-1's pin + 6 tests in 3 suites.
  - The not-done lines come first in L1's section, and no revert is in flight.
