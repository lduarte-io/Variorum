# Variorum for iPhone — The Soul Document

*Written 2026-08-04 at the author's invitation, at the v1 gate's close
("maybe even a 'mobile app soul' document where you distill ideas for
the architecture, ui, and purpose of the app to help with decisions").
**Canon for every mobile phase and consulted by every Mac phase
closeout** (the parity ledger below). The author guides mobile LESS
than the Mac — this document is what stands in for her in the gaps,
beside the recorded rulings it points to. It binds direction; the gate
record in `notes/plans/mobile-app-plan.md` holds the rulings verbatim.*

## 1. Purpose — what this app IS

Her daily-driver complement: *"like apple notes on the phone v.
computer"*. A **complete, comprehensive app** — *"basically just as
capable as the mac app… it can't be a very lobotomized version without
me missing functionality"* (the parity ruling, CoreDescription pillar
8's second supersession). The phone is where she writes in bed, on the
couch, away from the desk — capture, real writing, real editing, real
reading, takes included. It is NOT a satellite: it is the second full
citizen of one store.

**The soul test for any decision:** would she reach for the Mac
because the phone *can't*, or because the Mac is *nicer for this*?
The second is fine and permanent. The first is a defect unless it is
on the ruled exclusion list.

## 2. The bar — performance is identity (HER EXPLICIT BAR)

P1–P3 are the phone's invariants **verbatim**, and she has set the
number: *"I do not want the mobile app to choke even on 100k words"*.
The Apple-Notes-lags failure mode is banned on the phone exactly as on
the Mac — it is the app's founding grievance.

- **P1 on phone:** cost ∝ viewport + edit, never document/corpus
  size. Every list windowed (the Phase 10 window+probe discipline is
  already the mobile view models' shape — keep it).
- **P3 on phone:** ONE live editor ever; everything else is the
  read-cheap tier. The phone's calm default IS its performance
  architecture, same as the Mac.
- **The phone adds a constraint the Mac never had — MEMORY.** iOS
  kills apps at hard memory ceilings (jetsam). The 100k bar is a
  memory bar as much as a latency bar: measure peak memory, not just
  scroll/typing latency. Windowed reads and the read-cheap tier are
  what keep the ceiling far.
- **The executable form:** the parity round seeds a ~100k-word
  fixture post + a large corpus in the dev store; every stage's
  ladder includes a perf spot-check on it (typing latency, scroll,
  open-time, memory); the round's exit gate runs it ON DEVICE. The
  Stage 0 TK2 spike (kept as the iOS §5 executable) re-runs after
  each iOS point release — same corollary as the Mac's.

## 3. The architecture rule that makes parity CHEAP

**Brains live in `VariorumCore` (or `App/Variorum/Shared/`); platforms
own only faces.** This is the single most load-bearing idea for
mobile's future: parity is then inheritance, not reimplementation.
Proven three times already: the editor brain (`Shared/EditorBrain` —
identity, crystallization, markdown law), `VoiceTokens`, the shared
sync/auth shells. Consequences:

- A capability built Mac-side with its brain in app-local code is a
  **parity defect at birth** — the Mac phase should hoist the brain,
  or the ledger row records the debt explicitly.
- **Search (her named worry):** when the whole-library search row
  runs, its engine choice (FTS5 vs sweep vs index) MUST land in
  `VariorumCore/Queries` — never Mac-app code — so the phone gets
  search by composing a face. P1-on-phone (and memory) sits at that
  design table from the start: an index the phone can't afford is the
  wrong index. The search row's design sitting consults this document.
- The same rule reads in reverse: mobile never forks a brain. A
  behavior difference between platforms is either a RULED compromise
  (recorded) or a bug.

## 4. The decision grammar (how to shrink a surface without losing the soul)

When a Mac surface doesn't fit a phone, the shape changes and the
capability survives. The ruled tools, in order of preference:

1. **Same brain, phone-native face** (takes: swipe-peek + ✓ instead
   of the board; books: the note list instead of the shelf's columns).
2. **The workaround default** (her divide precedent — a simpler
   default so good it became the Mac's own; merge may follow the same
   road). Prefer inventing ONE honest simpler gesture over porting a
   ceremony.
3. **See-your-data** — *"if it exists on the mac app and is your
   information you should be able to see that it exists"* — viewing
   without a dedicated editor is a legitimate end state (references'
   "More info" list, scraps viewing).
4. **No-redirect** — "do it on the Mac" copy is a red flag; a road
   must exist on the phone, even a modest one, except where she has
   ruled the exclusion.
5. **Exclusion, ruled and recorded** — Compare · the scraps
   drag-into-note door · sticky-note/canvas editing · workspace &
   windowing · two-pane outline · expand-all-fans · side-by-side
   reference panel · ceremonies · iPad (PERMANENT: portrait-locked
   iPhone; declaring iPad capability forbids portrait-only — never
   declare it).

Calm default, depth on demand, is doubly true on a phone: one column,
one block blooming, machinery summoned per-block. The R58 lean —
one take at a time — is the phone's native takes grammar, and it
proved right. When in doubt, choose the calmer shape and record a
PROVISIONAL.

**Her sharpening of the doctrine (2026-08-09, at the parity chain's
close — verbatim, recorded for 13j's design sitting and every
ceremony-touching phase after it):** *"Truthfully, I thought merge
and divide were already overly fiddly on the mac app and I think
mobile is good for exposing complexity that can't survive a
simplified UI, because that's a sign it may be too complex period."*
The phone is not just a smaller surface — it is a COMPLEXITY TEST:
a capability that cannot survive the simplified UI is evidence
against the complexity itself, not merely a case for a mobile
workaround. This is the generalization of her divide precedent
(the workaround that became the Mac's default), stated as principle.
She is considering both structural-op cases fully before 13j builds
the Mac's default switches.

## 5. Platform truths (the fundamental differences — design around, never against)

1. **The app dies without warning** (background → suspend → kill).
   Pending buffers flush on background (shipped); any future
   multi-step flow must survive interruption mid-step or not exist.
2. **Text mutates in batches you didn't type** — autocorrect,
   dictation, predictive text strip and rewrite. Identity is a
   re-stamped projection, never attribute inheritance (the spike's
   headline; the DEBUG audit guards it). Any new editor behavior must
   pass the autocorrect/dictation test on device.
3. **Offline is the phone's NORMAL.** Sync races and S5
   conflict-as-variant fire more on mobile than they ever did between
   two desks. A conflict variant landing on the phone must be
   DISCOVERABLE there (the takes badge is the natural face) — a
   parity-round check, and a standing acceptance item.
4. **Memory ceilings** (§2). 5. **Portrait iPhone, forever** (§4.5).
6. **Dynamic Type and VoiceOver are phone-native expectations** —
   the token layer should scale with the user's text size where it
   can, and the custom surfaces (badge, peek strip, seams) need
   accessibility labels; audited at the parity round's Stage E
   (TestFlight & store readiness — her 2026-08-04 directive), owed
   before TestFlight strangers.
7. **The sandbox**: no folder bridges, no bulk import; share-sheet
   is the export grammar (FUTURE LIST). 8. **The A4 fence**: Debug =
   dev store, never her corpus; Release installs are the real app
   (M14: Xcode drops now, TestFlight at stability).

## 6. THE PARITY LEDGER (the mechanism that keeps mobile whole)

**The protocol (author-invited, 2026-08-04; direction refined at the
gate's close the same day — two duties with distinct jobs, plus one
escalation):**

- **Mac phases RECORD (cheap, context-hot):** every Mac phase
  closeout adds a row here naming what shipped that mobile owes a
  version of — or states "nothing mobile-visible" in its closeout
  paragraph (the CLAUDE.md ritual line; a closeout without it is
  incomplete). The closing session knows exactly what it shipped;
  a mobile session months later re-deriving it from diffs would be
  expensive and lossy. Recording is the whole duty — Mac phases do
  NOT design mobile shapes.
- **Mobile phases ACT (judgment lives here, with this document):**
  every mobile stage/phase kickoff reads this ledger AND sweeps the
  closeouts since the last mobile phase (belt and braces — a missed
  line must not become a lost capability), then turns open rows into
  scope with the soul test and decision grammar applied. Mobile owns
  the judgment of what parity means per row.
- **CROSS-PLATFORM phases design TOGETHER (the escalation):** where a
  capability is inherently both-platform — anything in core or
  `Shared/`, sync semantics, 14b's E2EE device enrollment — mobile is
  IN the design sitting, not informed at the closeout: the ledger row
  is written at DESIGN time naming mobile's deliverable inside that
  phase (PL-5/PL-6 are this class). The test: if mobile's half could
  not be bolted on afterward without redesign, it is this class.

Mobile stages burn rows down and mark them. This replaces hope with
bookkeeping.

| # | From | What mobile owes | Status |
|---|------|------------------|--------|
| PL-1 | 13e (when it runs) | The takes vocabulary additions (reorder takes, move-take-into-block, copy-all-takes, takes-aware find&replace) — adopt into the phone's browser after the Mac lands them (the recorded L12 deferral) | waiting on 13e |
| PL-2 | Whole-library search row (when it runs) | The engine lands in core Queries (§3); the phone gets a search face; phone memory/P1 sit at the design table | waiting on the row |
| PL-3 | 13j (when it runs) | Trash/restore + restoration doors: phone parity at least to see-your-data (view the trash, restore a note; the per-post archived-blocks surface) | waiting on 13j |
| PL-4 | 13i (when it runs) | Smart-book identity changes flow through reading assembly (core) — verify the phone book list renders the hybrid correctly; no new face expected | waiting on 13i |
| PL-5 | 14a (closed 2026-08-04) | The suite sign-in through the shared shells — SHIPPED through the one shared seam at 14a (the `mobile`→`main` merge preceded the code batch by design): the direct email+password form IS the phone's sign-in door (AccountView via the Settings sheet; the iPhone-clip `minWidth` gated off; AutoFill `.textContentType`s on; mobile suite 172/24 green at the closeout). NO parity debt. | REMAINING: the live phone end-to-end sign-in verify at the next mobile session/install (the parity round's Stage A trigger — 14a's shared-seam landing — has now FIRED) |
| PL-6 | 14b (OPEN 2026-08-04) | DESIGN DONE at the 14b sitting with mobile in the room (R-4: passphrase-entry enrollment, identical flows both form factors; R-6: enrollment-only unlock, the biometric-later door held open; R-7: phone KDF latency measured as a ruled condition). Mobile's deliverable INSIDE 14b: the shared setup/enrollment flow working on the phone, the phone's fresh re-onboard pull over ciphertext at the gate (= the restore drill's device half), and the phone KDF measurement | **BUILD HALF SHIPPED (pre-Stage-A, 2026-08-04 — the flow-notes work order executed; record: `notes/plans/mobile-parity-round.md` PRE-STAGE-A):** final main merged (CF-1…CF-16 all inherited through the one seam); the lifecycle care VERIFIED (nothing tears the sheet chain down on scenePhase — same step, same words across background→foreground; kill-safety is the state-not-screen architecture, preserved untouched); the app-switcher SNAPSHOT COVER built PROVISIONAL (`SnapshotPrivacy` + `privacySensitive` on exactly the words display and phrase entries — the flagged consideration, recommended and built for her walk); BIP-39 entry ergonomics done (auto-capitals off on the phone, one shared `phraseEntryField`); mobile 175/26 green. **ROW CLOSED at the 14b closeout (2026-08-04): her drill's phone half PASSED LIVE** — CF-16's replaced state SEEN on the phone (both faces), re-enroll with the new passphrase, forget, the recovery-phrase road with her new 12 words, corpus reading throughout; the on-device KDF number stands at 0.16 s (the gate's measurement); **the snapshot cover ACCEPTED at her walk** (words redacted in the switcher, same words on return — her regenerate landed, which also proved the cover under a real confirm; the PROVISIONAL resolves ACCEPTED). One carried residual, deliberately NOT parity debt: the first-run FULL-SETUP visual walk still has no safe live subject until a non-her account exists — it rides 14c's stranger-onboarding acceptance by nature. NO PARITY DEBT from 14b. |
| PL-7 | 13h (when it runs) | Folder bridge is Mac/files-domain; results flow to phone via sync — expect "nothing mobile-visible" beyond verification, but the closeout must say so | waiting on 13h |
| PL-8 | 14c (closed 2026-08-11) | Multi-tenant + the tier + the account doors — NOTHING mobile-visible NEW by construction: the isolation is server-side + engine-wire (the phone's SyncSchema.lockstepVersion is 6 through the shared core, so the phone speaks the reborn mirror once rebuilt), and the account/tier/sign-up/re-key/deletion SURFACES all ride the shared `App/Variorum/Shared` seam (the phone got them at the 14c batches, exactly the PL-5/PL-6 pattern). TWO real mobile acts land at **14d**, not here: (a) **the phone RE-ONBOARD against the reborn mirror** — the 14c rebuild reset the mirror's changefeed, so the phone's saved cursor is stale and a re-onboard (fresh store, enroll by passphrase, pull-to-head — the 14b road) is the clean fix; NOTE the build version is THIS project's to confirm, not the Mac session's assumption — the mobile session's own 2026-08-11 merged-tree Release install (which carries 14c's lockstepVersion 6) went to her phone but needed the phone unlocked to mount, so whether the phone is already a marker-6 client (won't refuse on version) or an older build (refuses until updated) is a mobile-session fact; (b) **the PL-6 first-run FULL-SETUP visual walk** finally gets its safe live subject (a fresh stranger account) at 14d's stranger-onboarding validation — the residual 14b/PL-6 named. | **CLOSED at 14d (2026-08-16):** the phone re-onboard was NOT needed — DISCHARGED by her live confirmation (14c post-close: marker-6 build, unwrap-only repush, Keychain-held class keys; phone↔Mac sync works with no re-onboard, no passphrase); the PL-6 first-run full-setup walk rides HER RESIDUAL stranger walk (the 14d ruling — on her own time, instructions in the 14d plan; a simulator run named as the low-cost arm) |
| PL-9 | 14d (closed 2026-08-16) | **The account-sheet unification + the delegated bridge door reached the phone by construction** (all shared-seam: `AuthViews`, `SignInFlow`, `ErrorPresentation`, `BridgeStatusViews`): the Stargazing headings ("Sign in with your Stargazing account" / "Create your Stargazing account"), the Fragments row as "Journal bridge (Fragments)" with the ONE delegated browser connect door — the email+password form REMOVED (her password is retired server-side; the old form could only 422), the FlowError human voices, the fixed bridge-status string. Mobile owes JUDGMENT, not code: (a) verify the sheet reads right on the phone; (b) DECIDE the phone's bridge-connect door — it renders there but `bridge.allowsBridge` is false on the phone (a persisted session with no consumer; pre-existing shape, unchanged by 14d) — hide it, or keep it as account plumbing; (c) the iOS `presentationAnchor` arm of the rebuilt `SignInFlow` COMPILES but has never run on a device — exercise it once if the door stays. | waiting on the next mobile session |
| PL-10 | 13e (closed 2026-08-18) | **Takes & block management — the phone OWES doors for shared-core capability plus three design calls.** The core ops are SHARED (the phone can already run them; only faces are missing): (a) a **reorder-takes door** (`reorderTake` — the Mac wears ◀ ▶/▲ ▼ arrows on the take card); (b) the **duplicate-book-name guard** at `MobileCreateBook` + `MobileBookDetails`' rename (one line each — `assertBookNameIsFree` is in core; the Mac refuses at five doors); (c) **copy-all-takes** — `Queries.blockTakes` is core, the Mac's `TakeClipboard` needs a `UIPasteboard` twin; (d) **E5/E6 doors** (take-to-block-below · takes-to-blocks — the AR-1 ops are core; the Mac wears ⌥⌘⏎/⇧⌥⌘⏎ + menu rows). Design calls held for her: the phone's ●n comment marker sits TRAILING by its own M12 ruling while the Mac swept everything LEFT (13e batch 6 flagged, not changed — her call whether the phone follows); the margin-hover comment door has no phone hover twin (a tap shape is hers); callout swatches/emoji picker at her word (the phone's `MobileCallout`/`MobileBlockMenu`). The phone's future tag-face ✕/＋ grammar must HOIST `applyTypedPath` per §3, never copy it (the KnownIssues six-brains row's addendum). Batch 9's Keychain lazy-load fix reached the phone BY CONSTRUCTION (`Shared/`) — launch-path benefit, zero work owed. W26 is Mac-only by nature (no system-wide hotkeys on iOS; the share/shortcut road is the phone's future-list equivalent). | waiting on the next mobile session |
| **PL-12** | **13u (OPEN — her #2 priority, runs after 13l)** | **THE "DESIGN TOGETHER" ESCALATION, written at DESIGN time as §6's own rule requires — not at closeout.** 13u is a **cross-platform phase by construction**: **FOUR of its eight items are inherently both-platform**, so mobile is **IN its design sitting**, and the phase names mobile's deliverable INSIDE itself rather than leaving parity rows behind. **(2) the eager space-eater** — she reported it on BOTH apps; the fix lands in core/`Shared` and reaches both. **(4) the derived display-name snippet** — her own words, *"ONE brain… serving the Mac library, MOBILE'S LISTS, and capture alike"*; the snippet rule is a pure Domain function. **(5) cross-block edits** — *"the semantics are ruled HERE, once, for BOTH platforms"*, and her coordination flag names mobile round 2's **M1** as the same seam with the instruction that *the mobile session should know the direction before hardening any refusal*. **(6) dark mode** — **the PHONE's shipped dark mode is her named look reference**, so this is a Mac face catching up to a mobile one, the reverse of the usual direction, and the voice tokens are shared. **PLUS item 8**: 13u inherits mobile round 2's **editor-seam backlog** (the frozen-projection fan fence · the surviving O(N²) twin in `planVisibleTakeEdit` · the gap fence's missing Mac face · the empty-block dead plan · `CrossBlockRefusal`'s hoist), and **13l takes the four data-safety-shaped ones** (L-a…L-d) — **her 2026-08-23 ruling: the Mac phases leave mobile with NO known Mac or `Shared/` work.** **The §6 test is met:** mobile's half of items 2/4/5/6 could not be bolted on afterwards without redesign — item 5 in particular is one structural compound in shared code. | **OPEN — mobile is owed a seat at 13u's design sitting.** What mobile will owe afterwards is FACES at most, and possibly nothing: verify what 13u built before scheduling any of it |
| PL-14 | The post-13l polish round (closed 2026-08-25) | **THE RECOVERY MAP + THE VERSIONS FAMILY — the brains are shared; the phone owes faces built to the RULED design, never the mid-design** (her token instruction executed at this closeout: the mobile round's batch-6 plans updated — `notes/plans/mobile-round-2.md` §69). The letter: **(a) the FIVE-PLACES MAP** is the phone's recovery north star (where you left it · Archive, notes forever · the Trash, notes·books·blocks 30 days · this note's Versions · this block's History); **(b) ARCHIVE/TRASH SEPARATION reaches the phone in a mobile shape decided at its OWN DESIGN SESSION with HTML mockups** — her ruling verbatim in the round's plan: *"the phone will also have archive and delete separated and on mimicking the surfaces that the mac has decided on, in some way that works for mobile (make a note that it can have a design session and propose different designs to me with html when the time comes)"* — batch 6 does NOT improvise the IA; **(c) takes NEVER row in a global Trash** (`TrashScope` shipped BOTH platforms in-round — **the phone currently has a deleted-take DARK WINDOW**: invisible, un-restorable on the phone until its Block History/tray faces land; OPEN and hers to time — the round's handoff carries it); **(d) the Block History twin** (one face per block: savepoint runs · archived · deleted with clocks, NO purge door · came-from with ALL originals + one-button restore) absorbs PL-11(d)'s History-past region; **(e) the tray face** = Archived (kept) · Leaving (clocked blocks + collapsed takes disclosure, per-take Put back + Delete Now confirm-every-time) — unclocked originals are lineage-only (came-from), superseding PL-11(a)'s mid-design; **(f) the VERSIONS face** — Note ▸ Versions (the ops `saveNoteVersion`/`restoreNoteVersion`/`promoteNoteVersion` are core; the classifier already auto-hides versions from the phone's listings; the phone's door/listing shape is a design call); **(g)** one line: the phone's Put back/Delete Now accessibility labels are version-blind (LR2-4); **(h)** free by construction: the alarm/positive voice tokens, the shared confirm copy (Empty Trash's exact-rows scope + saved-version counts), the evolved purge-door rule (trash surfaces only — binds the phone identically). The phone's Aa bar needed nothing — the Mac adopted ITS idiom (reverse parity, like dark mode). | waiting on the next mobile session (batch 6 + the archive/trash design session) |
| PL-11 | 13j (closed 2026-08-19) | **Deletion, the Trash & the purge — the phone INHERITED the brains by construction and owes the FACES.** Core/Shared carried over free: the 30-day `TrashWindow` fences on every recovery query, `archiveBlock`/`unarchiveBlock`, `restoreVariant`, `requestPurge`, the purge janitor + `LocalPurge` + the verdict hardening (riding `SyncSession`/`AppServices` — Shared), the savepoint-cadence ops + both new settings, and the ledger/returner machinery. The phone OWES: (a) the per-note TRAY face (deleted + archived + preserved originals, Put back); (b) the TRASH surface (clock, kind/date filters, Put back; Delete Now/Empty Trash IN-TRASH-ONLY + confirm-every-time — her round-3 rider binds the phone identically); (c) the archive doors; (d) the History-face past region (the lineage row + deleted-take rows); (e) its OWN on-leaving savepoint hook (the cadence SEMANTICS are synced settings, the leaving FUNNEL is per-platform — the 13j batch-5 hand-off); (f) the cadence + pruning settings rows on the phone's Settings twin. NOT owed: the divide/merge quick defaults (the phone SHIPPED them first — Q-M2/C5; the Mac caught up at J4/J4b; the ceremonies stay Mac-only per her exclusions); the ⌘Z-hint (no chord culture on the phone — judgment, not code); W26-class hotkeys. 13l will add its own line (the lock's Face ID twin). | waiting on the next mobile session — **(a)/(d) SUPERSEDED-IN-SHAPE by PL-14** (the post-13l polish round's ruled design: the tray's three-section/leaving shape; Block History absorbs the History past region; takes never global) — build to PL-14's letter |
| PL-13 | 13l (closed 2026-08-24) | **The data-safety floor — the brains landed in core/`Shared` by construction; the phone owes FACES.** Free by construction: the second-destination backup legs + retention + integrity (`StoreBackup`/`MarkdownInsurance` — Shared), the sync-status standings (Shared), `SecretCheck`'s model (Shared, host-agnostic by design), the identity-projection audit (the phone was its SOURCE and is now a five-line consumer of the hoisted brain — and the macOS-26 widening finding in TEXTKIT2 §3 rode it), the shared deletion-confirm wording, the status-aware Trash put-back receipts (the phone's Trash already speaks them), and the bridge deletion-travel engine (the phone benefits when 13v gives it rounds). The phone OWES: (a) the Data Safety face twin (backup freshness/destination/log — the iOS folder pick via the Files picker is the design call); (b) the sync-status slot on the phone's Settings twin; (c) the `SecretCheck` face (Face ID framing; the model needs only a host); (d) a `.md`-insurance destination story on iOS (candidate, same Files-picker call); (e) NOTE-level multi-select + delete-all (the Mac's P-0-fixed bulk bar; the phone's block multi-select is its batch 7 — the note-level twin is a design call). NOT owed: the app lock (MOVED to 13p at her 2026-08-24 ruling — 13p Batch 4 builds the Face ID twin INSIDE that phase, superseding PL-11's closing sentence); the runbook (a Mac-home document — the phone points at it at most). | waiting on the next mobile session |

## 7. How to run mobile phases

The active plan: `notes/plans/mobile-parity-round.md` (stages A–D,
each its OWN `/architect-phase` invocation). **Invoke with the mobile
plan NAMED explicitly** — e.g. `/architect-phase mobile parity stage
A` — from the `~/dev/variorum-mobile` worktree; a bare
`/architect-phase` resolves to the MAC master-plan pointer and is
always wrong for mobile. The branch & merge discipline in that plan
binds (pull `main` at stage kickoffs and batch boundaries; prompt her
before merging outward). After the parity round, future mobile phases
are planned against this document + the ledger above.
