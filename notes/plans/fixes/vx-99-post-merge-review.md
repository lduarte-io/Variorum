# VX-99 — post-merge cold review (Fable, 2026-10-08)

Diff reviewed: `git diff 9819bff8^1 9819bff8 -- App Sources` (the whole VX-99 landing: `PostureSwitch.swift`
+285, `PostureSwitchModel.swift` +193, `PostureCopy.swift` +77, `ProtectionPane.swift` +23,
`MobilePostureSheets.swift` +17, `MobileProtectionSheet.swift` +3, `PostureSwitchTests.swift` +1280; zero
`Sources/`, verified by `--stat`). Worktree HEAD (main) differs from the merge ONLY in
`PostureSwitchTests.swift` (+120, VX-106's), so every production file was read as merged, whole:
`PostureSwitch.swift`, `PostureSwitchModel.swift`, the touched `PostureCopy` region, both pane diffs,
`RotationMarker` (`Sources/VariorumCore/Sync/CorpusRotation.swift`, read-only), and all 18 new/changed
tests against the code. Anchor: the record `vx-99-pro-castle-apple-wrap.md` whole + all three ladder rounds
with their dispositions. Canon read: CLAUDE.md, the three auto-loaded docs, SyncSpec whole,
`pre-13x-postures-design.md` §1 (decisions 1–35), §3.4 (the audit walked), §3.5, §3.6, §4, §5, §7. No
"Review foci" section exists in the record or beside it (checked; all three rounds recorded the same). Mac
suites NOT run (stage-gated, no claim held); zero `Sources/`, so the core suite cannot have moved from the
13x/VX-83 baseline. Commit hygiene: 54 commits in the PR range, zero `Co-Authored-By`/`Claude-Session`
lines (grep over `%b`). One toolchain fact verified by a scratch compile: an enum case with a defaulted
associated value (`switchInProgress(RotationMarker.Step, act: CeremonyAct? = nil)`) compiles and derives
Equatable on this toolchain.

**Standing of this review:** QUESTIONS #204(d) records that round 3's delta closed without a fourth cold
review. This review covered that delta with fresh eyes along with the whole diff — the round-3 MAJOR fix's
blast radius was independently confirmed (grep: `followedAnotherDevicesSwitch`/`otherDeviceDay` are read
ONLY by the two Done selectors, `PostureCopy.swift:868/:941/:950`, so `ownWriteLanded` gates the face and
nothing else), and `tighteningPosture` was traced through `moveCustodyForSwitch` on every arm. Nothing new
at BLOCKER or MAJOR was found.

## Findings (severity-ranked)

**Tally: 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT.** Every heavier candidate I traced resolved either into
the code behaving as canon says, or into a residual the record already names and dispositions (VX-107's
double-crash/words class, VX-108, VX-109, VX-110, #204(b)/(c) — each re-verified as genuinely covered, see
the clean bill).

**[NIT] · App/Variorum/Shared/PostureCopy.swift:853 vs :920 · The ledger-61 Done family now splits its own
case mid-family: the shipped `enteredCastleAfterAnotherDevice` renders "The twelve words shown here are
NOT your account's" (shouty caps, rendered app text — against the author's recorded sentence-case rule)
while VX-99's new sibling `keysReplacedAfterAnotherDevice` (:920) deliberately sentence-cases the same
clause ("are not your account's").** Evidence: both strings render in the same Done slot
(`ceremonyDoneBody` branch 1 picks one by `outcome.entersCastle`), so the same user can meet both
spellings of one sentence; QUESTIONS #204(b) quotes only the new sibling, so a 13s re-voice keyed off the
bundle could fix one and leave the caps twin. Copy-only, no pin (no failing-on-old test exists for case).
Fix: one line added to #204(b) naming BOTH strings for the 13s re-voice (or lowercase :853 now — a
one-word copy edit inside an already-PROVISIONAL family).

**[NIT] · App/Variorum/Shared/PostureSwitch.swift:82–84 (the `switchInProgress` doc) + notes/QUESTIONS.md
#204(c) · The busy-arm justification "no marker exists to read" is half-true: during a RESUME road in
flight a marker DOES exist — the busy guard just cannot read it.** Evidence (traced): the resume road runs
with the marker still set; a ceremony door pressed meanwhile hits `runCeremony`'s `guard !busy` (:509),
which throws `switchInProgress(.vaultWrite)` with `act: nil` → `message(for:)`'s bare arm → `resumeBody`
("Entering Castle didn't finish…") over a pending Replace All Keys — the exact wrong-act wording #204(c)
records, reachable on a path whose stated justification ("no marker") does not hold. The faces' Finish
buttons are `.disabled(model.busy …)` on both platforms, so the reachable press is another surface's
ceremony door, not a double-press. Behavior class is already #204(c)'s residual (13s's one sentence); this
is a precision note so 13s's re-voice covers the marker-pending busy case too. Doc/copy only; a pin would
be hollow (the wording residual is already recorded as shipped-by-ruling).

**[NIT] · notes/plans/fixes/vx-99-pro-castle-apple-wrap.md, THE CLASS SWEEP rows 1–2 · Line-number cites
rotted again across rounds 2–3** (e.g. row 1 cites ":1092/:560/:638"; the merged file has the writer at
:1105/:1147, the enrolled decision at :611–:622, the resume decisions at :1443–:1460). Round 3 NIT'd
exactly this and the orchestrator ruled "the fix session may tidy the line numbers; the move is recorded,
not made" — so this is a re-note for the next reader, not a new obligation: grep the SYMBOLS
(`writeNewKeyFile`, `appleHeldCopyForStandard`, `resume`'s `.vaultWrite`/`.reencrypt` arm), not the lines.
No action owed beyond the standing disposition.

## Residuals re-verified as genuinely covered (not new findings; each has a traced mechanism AND a recorded owner)

- **The second-crash ambiguity on an another-device road** (the rewritten `.reencrypt` marker carries
  `follow: true`, so a SECOND crash makes `ownWriteLanded` false at the next resume and the words-claim
  Done returns on a road whose own write may have landed) — traced at `PostureSwitch.swift:1505–1509` +
  `:1550`; exactly round 3's "the `.vaultWrite` case and the second-crash ambiguity stay with VX-107".
- **The latent words rule on the own-road resume** (typed words land in the key file unverified when
  custody already holds M′) — unreachable in the app (both resume doors pass `recoveryWords: nil`,
  `PostureSwitchModel.swift:637`); VX-107's recorded class.
- **S1 under a stale Castle read / the `.rekeyLibrary`+ arms holding no vault** — round 3's RESIDUALS
  section, by trace, narrow; the announced-follow doctrine bounds both.
- **Use Castle's local-only road for an enrolled-SHAPED library and the rekey banners** — VX-110 / round 3
  MINOR-2's ticket; **the `CorpusRotation.begin` re-fetch race** — VX-109 (`Sync/`, Fable's);
  **the Use Castle / Leave Castle posture-read doors** — VX-108.
- **The resume-road Apple re-read without a vault-id check** (`:1523`, `appleKey: vaultSaysCastle ? nil :
  leaves.appleKeys.read()`) — round 3's SPECULATIVE NIT, recorded; the follow's bare read is the DESIGN
  (§7's follow into Standard: "A from their own iCloud Keychain"), so any tightening must stay own-road.

## Clean bill (checked, found solid)

- **The headline fix, §3.4's audit walked on every key-file-writing road:** `writeNewKeyFile` takes the
  caller's `AppleKey?` and never reads A itself (:1147–:1189); the ceremony's enrolled road passes exactly
  the belt-verified A, present iff the vault write carried an Apple-held copy (:611–:622); the local-only
  road is Use Castle's alone since the F4 guard (:535) and passes nil (:699); the follow reads A only when
  the fetched vault says Standard (:860, :879); the resume's enrolled arm likewise (:1523). The Castle row
  of §3.4 (L′ under P, W, M only) holds on all four; Standard's §7-step-5 parenthesis holds on all four;
  entering Castle is nil everywhere. Her Pro's mechanism is gone.
- **Round 1's MAJOR (the vault's word):** door (:398–:412), belt (:1275–:1288) and the F2 screen fact
  (`vaultHasAppleHeldCopy` → `accountPostureIsStandard`) read the same word; the readable/vault-id
  refusals kept; the caller's `entersCastle ? nil :` stays load-bearing for the enter-Castle road (its
  fetched vault is still the old Standard one). Decisions 8/30/35 and §5's Replace-All-Keys row honored.
- **The resume arm whole (rounds 1–3 compounded), re-traced from scratch:** the stamp-first discriminator
  (:1411–:1416) with the restart check ordered before it (:1375, requires `previousCorpusKey == nil` so a
  restart can never fire into a live rotation); `roadEntersCastle`'s three-way rule; the marker rewrite
  keeping the ACT's `entersCastle` on an own road (the F3 correction — S1's Done and the pane label
  depend on it) and the road's on follow/another-device roads; `ownWriteLanded` gating ONLY the Done flag;
  `tighteningPosture` overriding custody ONLY toward Castle, the into-Standard move left to the ready's
  announced follow (the MINOR-1 pin's tail proves the notice fires: key file `apple` + gated shape →
  `reconcileFollow`'s :707 arm). Every S1/S2/pin-(e)/double-crash world was re-derived by hand from the
  code and matches its pin's expectations line for line.
- **Round 2's F1 selector and both faces:** `CeremonyAct(resuming:)` maps every marker shape (no
  `.vaultWrite` follow marker exists, so a restart's act is never `.follow`); `ceremonyDoneBody`'s branch
  order puts the outcome first; branch 4 is reachable only via the resume's S-roads and names the vault's
  last writer and day (`day(from:)` exists, honest fallbacks); the fresh Use Castle road cannot reach it
  (`runCeremony(entersCastle: true)` always returns `entersCastle: true` or the flagged follow outcome).
  Grep confirms no production branch still reads `mode == .replaceKeys`; `authorize`/`commitNewPassphrase`
  key on `act`; the restart re-enters the marker's own ceremony through the restore hold + the shared
  `replaceKeysFrontCheck`. Mac and phone faces are line-for-line twins; both disable Finish on `busy`.
- **Round 2b:** the `!isResume` exemption is sound (the resume is the only road that can finish a
  one-device account's rotation; `.enter`/`.replaceKeys`/`.leave` keep decision 32's door, pinned); both
  panes' captions ride the selector; `switchInProgress` carries the act at the three pending-marker sites,
  `message(for:)` matches `(_, act?)` before the bare arm, and no production code compares the error by
  value (grep re-run).
- **The F4 guard:** sits after `busy = true`, before any pause/write; a refusal pauses nothing
  (`pauses == resumes` pinned); Use Castle's genuinely-local road untouched (decision 8's second
  sentence); the refusal wording reuses the switches' offline line by ruling (#204 carries the 13s note).
- **All 18 new/changed tests read against the code:** each pins the mechanism its doc comment claims; the
  harness's `vaultSaysCastle` lands the Apple-held copy through the real vault client (account-consistent
  Standard worlds); the six opt-outs are each a deliberate mismatch or the different-A sibling; the
  `defer`-in-loop teardown scoping is correct; the source-reading caption pin's working-tree caveat is
  recorded honestly in the record (V99-K ran over an edited tree by design). Red-on-old evidence (V99-A…N,
  each red on its own finding's pin alone, with the one mis-sited V99-I recorded and corrected as V99-I′)
  is internally consistent test-name-by-test-name; not re-run here (stage-gated, no claim held).
- **Sync shape and the hard invariants:** zero `Sources/` change; the one vault write path keeps its shape
  (one CAS write under the old proof — S1–S5 untouched); key files and custody stay local artifacts;
  nothing scales with corpus size; no text is copied across entities; no word-level tracking.
- **The doc deltas:** QUESTIONS #204's five arms match the code and the record exactly (the widened scope,
  both PROVISIONAL sentences verbatim, the busy-arm residual, the un-run round 4, the five tickets);
  MobileSoul PL-50 is accurate (Shared files; phone-visible = the two caption/refusal sites; phone
  build-for-testing recorded; her phone's key file facts match the record's read-only check); the
  in-flight row retired; the handoff is self-contained, checklist-first, and its "safe door for her words"
  instructions match `StoreLaunchGate`'s traced vault road from the record's §3.
- **Process:** pins-first per piece with a named revert each; repo-first records; the Sync/-custody slot
  held and `Sources/VariorumCore/Sync/` untouched; the ladder respected the cap with #204(d) recording the
  un-run round 4 honestly — which this review now discharges; no history rewrites; merge commit; no
  attribution trailers.
