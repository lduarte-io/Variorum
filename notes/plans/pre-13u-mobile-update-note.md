# Mobile update note — what the pre-13u round changed that the phone must know (2026-08-31)

**Provenance and purpose.** Written at the pre-13u round's closeout at the author's instruction
(her sign-off, verbatim: *"Remember to update mobile thoroughly at the end with whatever is new /
required - especially the encryption details / explanation, and the page redesigns"*), on the
14a mobile-update-message precedent: a SELF-CONTAINED note the mobile session reads when it
resumes, so it inherits DECISIONS rather than discoveries. Everything below is either (a) already
in the phone by construction (a `Shared/` brain or the engine), (b) built in the phone THIS round,
or (c) OWED — a face the phone must deliberately answer in its own shape (MobileSoul's
smaller-surface discipline; nothing bolted on). The binding records are named per item.
*(Ladder outcomes that touch mobile: see the PENDING block at the end — filled at the round's close.)*

## 1. The security posture — ONE account, ONE posture, both platforms (R-pre13u-7(f))

- **The binding presentation spec is `notes/plans/pre-13u-memo-security-shapes.md`** — the one
  law, the four credentials, the RECIPES format (no grand matrix; the three-row shapes summary is
  the only table), per-mode "what YOU need", per-shape "who this protects you from" + the two
  what-ifs, the ratified sync sentence, the compound warning, Shape 3 deferred. **Render, don't
  re-derive**: the keystone lines land verbatim (the Mac pins them byte-exact —
  `theExplainerCarriesTheKeystonesVerbatim`; the phone's faces must carry the same lines).
- **(a) Already in the phone by construction:** the `ProtectionShapes` brain (`Shared/`) with
  every keystone, the recipes, the shapes summary, the need-states, the three-value tier
  sentences, the checklist rows, the ceremonies' framings; the `ProtectionLegs` tier detection
  (covered / exposed / unknown); **the escrow/posture coupling** — the ONE behavior change
  (demanded at-open modes do not offer the iCloud spare; escrow's default follows the posture;
  `ProtectionDials.effectiveEscrowOn` is the one rule) — the phone sheet already stops offering
  the dial under demanded modes and speaks her why-sentence; the eye/peek control
  (`PeekableSecretField`) at every passphrase-family field; the phone's standing "ways back in"
  line; the exposed-tier nudge copy (`exposedNudgeHeadline/Body`, device-neutral — "this device").
- **(c) OWED — the phone's faces:** a **"How Protection Works" explainer** of its own (the Mac
  added a Settings tab rendering the memo whole + a pointer to the field guide's privacy chapter;
  the phone decides its shape — a sheet, a section — but renders the SAME brain); the protection
  sheet **leading with the live "ways back in" checklist** (`ProtectionShapes.checklistRows` —
  the Mac pane now leads with it); the **unchosen-state indicator** (the Mac's bottom-left family;
  NEVER "encryption off" — the store is always encrypted; the phone picks its placement); the
  **T1 stale-copy re-key warning** on the phone's Replace Encryption Keys road (the Mac wired
  `RekeyRecencyProbe` at its AppServices composition; verify the phone's door reaches the same
  probe — the count-and-dates warning is the ruled form, "the server holds N notes this copy
  doesn't have, newer versions of M others, the latest from <date>"). **One rule: no different
  settings for one account on mobile + mac** — the dials, the modes, the coupling read the same
  on both; only the faces differ.
- **The T2 verification half** (proving the escrow probe on a machine that isn't hers) rides 13r's
  Sparkle/fresh-download walk — not mobile's.
- The phone's tutorial privacy lesson was checked for drift at wave 2a (no drift); the Mac's
  chapter now teaches the coupling truth + spare-key-is-a-key + the sync sentence — align the
  phone's lesson to the same truths when it is next touched.

## 2. The page redesigns — surfaces the phone must deliberately answer (the tenth wave)

Her words: *"with the new act 10 edits to notes to have that block page & outline + pages/google
doc looking page + a read page, that mobile is going to have to think of how to handle all of
those items."*

- **The note mode row is now Write · Takes · Index · Read · Lenses · Compare · Blocks · Canvas
  (⌘1–⌘8).** New: **Index** (headings become sections, blocks nest under, a scroll-synced
  read-cheap pane; names/first-sentences derived at read time, never stored — the shared brain is
  `Shared/NoteIndexOutline`, with a DRIFT PIN against `MarkdownRendering`) and **Read** (a
  read-only projection page with a MINIMAL companion outline; a click lands in Index at that
  block). **Blocks** is now the poweruser WORKBENCH (per-row facts via core `Queries.blockWorkbench`,
  multi-select + bulk bar, a context panel). **OWED:** the phone's own answers — per MobileSoul,
  a narrower shape is legitimate (a Read page + a minimal outline is likely the phone's first
  citizen; the workbench may compress); the brains are shared, the faces are the phone's.
- **The Book view** gained word-tabs **Outline · Index · Book · Read**, an Index book view (sharing
  Outline's `BookStructureModel.grouped(entries:)` brain — NOT the note's heading derivation,
  chapters being real rows), and Outline's **details gutter** (metadata to the side, never below
  the opening paragraphs). **OWED:** the phone's book surfaces decide what of this they carry.
- **Compare + Lenses** were rebuilt as a flow on the Mac (an offer page with the note picker; the
  explainer behind a ?). Compare and lens-style surfaces are named Mac-only exceptions in
  CoreDescription §8 — nothing owed unless the phone's lens surface exists.
- **The Snippets refresh:** the scrap-area vocabulary is **Snippets** in every UI string
  (`container.kind='pool'` stays the model term); **groups** is the container noun; groups get
  new/rename/delete/move doors; **delete-group rides the ordinary Trash road** — the Trash learned
  `TrashItem.Kind.snippetGroup` end to end, and **the phone composes it with zero mobile edits**
  (verify its Trash rows a deleted group as a group). **OWED:** the phone's snippets surface adopts
  the vocabulary (no "pool" strings) and decides whether it offers group management.
- **The Pool page + the note picker:** the Mac's Pool is calm cards with a searchable
  add-to-book picker (`Core/Views/NotePicker.swift`, Mac chrome); the picker's RANKING rule
  (version peers float stably; recent-first inside partitions; day detail suppressed when the
  title is the day) is the rule to mirror wherever the phone picks a note from the corpus.
- **The style grammar:** her own observation — the mockups *"match the mobile app's modern
  feeling"* — so the Mac converged TOWARD the phone; the committed reference is
  `notes/plans/pre-13u-mockups/blocks-and-snippets.html`. Nothing owed except cohesion awareness
  (13u2 carries the Mac continuation).

## 3. The sample library and first-run — BUILT in the phone this round (Act 0)

- **Seed-on-first-write (R-pre13u-1):** the starter Journal is minted by the FIRST WRITE, never at
  launch; the 20-second wait and `SyncGate.hasSyncedCleanly` are DELETED; an account-owned store
  skips (the real Journal arrives by sync); empty-state copy names both roads (start one / sign
  in). Occasion: `MobileFirstWriteFurniture` via `AppSession.noteFirstWrite()` at five doors.
- **Sherlock on the phone (R-pre13u-8):** a phone-only store seeds the sample library at the same
  first-write moment (the seeder is hoisted to `Shared/SampleLibrary/`, 561 KB in the phone's
  bundle); the **pristine-copy dedupe** converges two seeded copies via sync (both pristine → one
  survives; an EDITED copy is never silently retired) beside the **Journal-keeper repair** — both
  in the engine (`Sync/`), both platforms by construction. **OWED:** the phone's face for the
  ruled **restore door** (the Mac: Help ▸ Restore the Sample Library — mints only what is
  missing; MobileSoul PL-17's owed row).
- The midpoint review's mobile fixes (m2 composition pins for the empty states; m3 the
  first-write occasion's logging + the dead `lastOutcome` removed) — see PENDING.

## 4. Environment facts the mobile session should know

- The bare `xcodebuild -scheme VariorumMobile` now resolves to "My Mac (Designed for iPad)" and
  fails on the iOS provisioning profile since the 2026-08-30 signing change — pass the explicit
  simulator destination (the wave 2c record carries the working command).
- `notes/SessionResiliencyProtocol.md` (+ the mobile seat's own addendum) binds every session.

## PENDING — filled at the round's close
- [x] Ladder R1 findings that touched mobile: **F9** — `MobileStarterJournal.mint` now routes through `shelveInDailyJournalBook`'s ensure (one door, one rule; zero literal profile writers); **F12** — the phone's Sherlock story imports are PACED behind pending autosaves (`AppSession.hasPendingAutosave`, `.utility`, 3 s cap) so first-write typing never queues behind a story turn; **F6/F1** — the Journal-keeper predicate + arrival-order independence (engine-side, both platforms by construction). Round 2 pending.
- [x] Midpoint m2 (composition pins for the empty states — the shelf's is a mounted-accessibility pin because its empty state sits inside a `GeometryReader`) and m3 (`first-write-furniture` logging per outcome; `lastOutcome` deleted). Mobile suite after R1 fixes: **607/97 + 2 standing**.
- [ ] The MobileSoul ledger row(s) written at closeout (cross-reference).
