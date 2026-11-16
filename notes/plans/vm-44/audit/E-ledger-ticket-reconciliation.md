# E — Reconciling the recorded mobile obligations against today's tree

*VM-44 audit, reader E. Read-only. Tree: `~/dev/variorum` main @ `5dde1bcf9` (2026-11-12). Linear read for ticket
bodies (titles alone were not enough). Every status says how it is known: **VERIFIED** = I read the code or record at
the cited line; **INFERRED** = reasoned from records, with the source named.*

**Status words.** STILL OWED · DISCHARGED (by what) · STALE (the rule it mirrors moved, or the surface it names is gone) ·
DUPLICATE OF … · UNCLEAR. Where one source row carries parts with different truths, it is split into sub-rows.

---

## 0. What matters most (read this first)

1. **Her phone is probably not syncing today.** `SyncSchema.lockstepVersion = 15` on main
   (`Sources/VariorumCore/Sync/SyncSchema.swift:170`); marker 15 (VX-808's v1_37) was deployed at the Nov 7–8 sitting.
   Her installed phone build is VM-8's (2026-10-26, marker 14), and no phone install is recorded since (VM-32, "install a
   phone build carrying the VX-669 fix", is still open). Under the §12 grammar a marker-14 client refuses a marker-15
   mirror. INFERRED (records + the marker value) — **confirm on her phone before anything else.** No ledger row or
   ticket says "put a marker-15 build on the phone"; PL-71 only notes the bump "binds the phone's track".
2. **The two highest-value recorded obligations are both still owed and both on the surface she complained about:**
   the quick note still runs the old one-block rule with "⏎ opens it" (PL-27; `MobileQuickNote.swift:19-23,55`), and
   the Library rows still carry no preview (PL-26; zero phone refs to the shared `NoteCardFace`).
3. **The whole 13i family is absent on the phone** — no wings, no shelves, no Arrivals, no Owned/Sealed doors, no
   archived-books group (PL-42…PL-47, VM-6, VM-42). The phone mints in Home and lists store-wide
   (`MobileCreateBook.swift:132`). This is her "no different wings (!!)".
4. **The palette and the voice default both diverge from her stated direction.** The phone calls the two-parameter
   `VoiceTokens.resolve(voice:dark:)` at four sites (no palette at all) and defaults to Terminal
   (`MobileVoicePreference.swift:31`); the Mac's fresh store is Study with the sea-glass palette. Her 11-12 words: "the
   study mode especially. the sea greeen theme". Chrome text is a fixed 11.5 pt in every voice
   (`Shared/Theme/VoiceTokens.swift:296,332,369,406`) — her "weirdly tiny font".
5. **Her lock request collides with a recorded rule.** The phone locks the moment Variorum leaves the screen in Castle
   (`MobileRelock.swift:46-51`, `locksOnLeaving` = Castle always), per the "re-lock on sleep / screen lock is always on
   in Castle" reading. VM-25's idle dial would not help, because the leaving lock fires first. A grace window is a change
   to the phone's reading of that rule — her call, checked against CastleRules at design. Her "Lock Now… like the mac"
   IS VM-25 (still owed).

---

## 1. The reconciliation table

### 1a. MobileSoul §6 — the parity ledger (every row, PL-1 … PL-73)

| Id | What is owed | Status today | Evidence | Disposition | Area |
|---|---|---|---|---|---|
| PL-1a | A reorder-takes door | DISCHARGED — round-2 batch 7, merged at VM-5 | VERIFIED `Features/Takes/MobileTakesBrowser.swift:549-611` (`ops.reorderTake`) | close | Takes & Lenses |
| PL-1b | Take → its own block; all takes → blocks | DISCHARGED — batch 7 | VERIFIED `MobileTakesBrowser.swift:653-699`; `MobileTakesBrowserView.swift:157-164,511` | close | Takes & Lenses |
| PL-1c | Copy all of a block's takes | STILL OWED | VERIFIED no copy-all caller on the phone; `MobileNoteClipboard.swift:33-38` names "R11 (copy all takes)" as the unbuilt composer; `TakeClipboard` is Mac-local (`Variorum/Features/Takes/TakeClipboard.swift`) | keep; carries the `TakeClipboard` hoist (#199) | Takes & Lenses |
| PL-1d | Takes-aware find and REPLACE | STILL OWED | VERIFIED the phone's find is the system navigator with `showingReplace: false` (`Features/Write/MobileEditorViewModel.swift:1022-1028`); the route's `.refuseFindReplace` arm is undeclared there (`:1704`); `FindReplaceGate` is Mac-local (`Variorum/Features/Editor/EditorFind.swift`) | needs her call (v1 or later); carries the `FindReplaceGate` hoist | Editor |
| PL-2 | A whole-library (body-text) search face over the core engine | STILL OWED | VERIFIED Library search is `Queries.searchCatalog` — titles, names, dates (`Features/Shell/MobileLibraryViewModel.swift:15-17,349-358`); zero phone refs to `searchPassages`, `SearchQuery`, `Shared/SearchLanding.swift` | keep; ONE search ticket family with PL-47b, PL-49 (VX-83) and VX-819's faces | Search |
| PL-3 | Trash and restore doors (see-your-data) | DISCHARGED — batches 4/6a/6b/6c, merged VM-5 | VERIFIED routes `.trash`/`.archive` (`Features/Shell/MobileShellView.swift:37-44`); `MobileTrashView.swift`, `MobileArchiveView.swift` | close | Library & sidebar |
| PL-4 | Verify the phone renders 13i's hybrid books | STALE — superseded by the fuller PL-42…PL-47 rows | INFERRED from those rows; VERIFIED the phone is wing-unaware (`MobileCreateBook.swift:132`) | close into VM-6 | Books |
| PL-5 | The live phone sign-in verify | DISCHARGED — VM-8's device moment (sign-in standing, the join made) | VERIFIED `notes/plans/vm-8-castle-catchup.md:1093,1107-1108` | close | Castle & sync |
| PL-6 | 14b's phone enrollment flow | DISCHARGED at 14b (that road later replaced at VX-329 and rebuilt at VM-8) | VERIFIED the row's own CLOSED cell; PL-51/PL-60 | close | Castle & sync |
| PL-7 | 13h folder bridge: confirm "nothing mobile-visible" when it runs | STILL OWED — dormant; 13h has not run | VERIFIED `notes/DetailedPlanForPhases.md:53` (row 14 pending) | keep as a watch line, no ticket | Import & export |
| PL-8 | 14c's phone re-onboard | DISCHARGED at 14d (her confirmation) | VERIFIED the row's CLOSED cell | close | Castle & sync |
| PL-9 | The bridge door's judgment on the phone | STALE — the Fragments bridge retired 2026-09-04 | VERIFIED the row's dissolved cell | close | Settings & onboarding |
| PL-10b | The duplicate-book-name guard | DISCHARGED — 4.5d; now per-wing (PL-69) | VERIFIED `MobileCreateBook.swift:132,139,150` | close | Books |
| PL-10 calls (i)(ii) | The ●n comment marker's side; a tap twin for the margin-hover comment door | STILL OWED — her calls never made | VERIFIED the marker sits "at the end of its LAST line" (`Features/Write/MobileBlockDecor.swift:25-26`); the callout emoji takes a first-line reservation INSIDE the text measure (`:15-21`). The Mac's rule has since moved: decorations render in the gutter and the measure never moves (AppSpec §12) | needs her call — the question is now "follow the gutter rule or not" | Editor |
| PL-10 calls (iii) | Callout swatches and emoji picker | DISCHARGED — batch 7 (forked, see VM-1) | VERIFIED `MobileEmojiField.swift`, `MobileCallout.swift` | close; the fork stays on VM-1 | Editor |
| PL-11a–e | Tray, Trash, archive doors, History past region, the leaving savepoint | DISCHARGED — batches 4/6a/6b/6c | VERIFIED `MobileNoteTray.swift`, `Features/Takes/MobileBlockHistory.swift`, `MobileTrashView.swift`; leaving road per the row | close | Library & sidebar |
| PL-11f | Savepoint-cadence and pruning rows in the phone's Settings | STILL OWED | VERIFIED Settings carries Voice · Sync · Protection · Acknowledgments · Tags · Diagnostics, plus DEBUG-only Tutorial and Performance rows (`Features/Shell/MobileSettingsView.swift:108-364`); zero refs to `savepoint_cadence` | merge into VM-11 | Settings & onboarding |
| PL-12 | Mobile's seat at the 13u design sitting | STALE — 13u ran as 13u1–13u4; its phone faces became PL-23/24/25–36 | VERIFIED those rows | close | Editor |
| PL-13a/d | A Data Safety face; a `.md` insurance destination | STALE — PL-20 ruled the backup offer not owed on the phone (no picked-folder road) | VERIFIED PL-20's "NOT owed" cell | close with PL-20's reason | Castle & sync |
| PL-13b | A sync-status slot in the phone's Settings | DISCHARGED | VERIFIED `SyncStatusRow` at `MobileSettingsView.swift:134` | close | Settings & onboarding |
| PL-13c | The secret-check face | DISCHARGED — VM-8 unit 2 | VERIFIED `MobileRoadSecretCheckDoor` (`Features/Protection/MobileProtectionScreen.swift:82`) | close | Castle & sync |
| PL-13e | Note-level multi-select and delete-all | DUPLICATE OF VM-31 | VERIFIED no selection mode in `MobileLibraryView.swift` | merge into VM-31 | Library & sidebar |
| PL-14 | The recovery map and the Versions face | DISCHARGED — batches 6b/6c | VERIFIED the row's CLOSED cell; `MobileVersions.swift` | close | Library & sidebar |
| PL-15 build | 13p's phone protection faces | STALE — built at 13p, deleted with today's road at VX-329 (PL-51), rebuilt on the new road at VM-8 (PL-60) | VERIFIED `MobileSettingsView.swift:166-167` comment; PL-51 | close | Castle & sync |
| PL-15 walk | The live Face ID walk | DISCHARGED — VM-8 ("faceid is looking good") | VERIFIED `vm-8-castle-catchup.md:1107-1108` | close | Castle & sync |
| PL-15 perf | The on-device perf and memory leg | STILL OWED | VERIFIED still listed on VM-13; no record it ran | merge into VM-13 / the lag trace | Performance |
| PL-16 | The custody guard (informational) | DISCHARGED — its own cell says nothing owed | VERIFIED row | close | Castle & sync |
| PL-17 | The phone's sample-library restore door | DUPLICATE OF VM-29 | VERIFIED the restore rows are `#if DEBUG` only (`MobileSettingsView.swift:294-330`) | merge into VM-29 | Settings & onboarding |
| PL-18a | "How Protection Works", the checklist lead, the unchosen indicator, the T1 verify | STALE — retired by the Castle rebuild | VERIFIED VM-8's old-scope table (`vm-8-castle-catchup.md:160-170`) | close | Castle & sync |
| PL-18b | Faces for the note modes (Index · Read with a minimal outline · the Blocks workbench) and the Book redesign | STILL OWED | VERIFIED the phone's routes are book · bookRead · note · trash · archive · versions · protection (`MobileShellView.swift:28-52`); a note has Write, the takes browser, lenses and the block list — no per-note Read, Index or Outline | needs design: which modes are v1 | Editor |
| PL-18c | The Snippets vocabulary and groups | STILL OWED — the phone's words are STALE | VERIFIED the phone says "scrap", "+ new scrap", "pool: …" (`Features/Shell/MobileScraps.swift:266,291,326`) | needs her call — her gate ruling put "snippets" on the not-replicated list, yet the phone ships a scraps room (see §3) | Library & sidebar |
| PL-19a | The mode order, with Read's edit · read switch | STILL OWED | as PL-18b. The row's "the phone has neither Compare nor Lenses" is STALE: the phone has lenses (`Features/Takes/MobileLenses.swift:1-30`) | merge with PL-18b | Editor |
| PL-19b | One current block across modes | STILL OWED | INFERRED: no current-block memory on the phone (zero refs to a `CurrentBlockMemory` analog) | fold into the mode design | Editor |
| PL-19c | The scrolled-open door: read surfaces land Write at the tapped block | STILL OWED | VERIFIED `MobileReadView` opens by note id only (`Features/Read/MobileReadView.swift:36,44`); zero refs to `Shared/LandingTarget.swift` | keep | Books |
| PL-19d | The `#` tag door's shape (one door, an inline field) | UNCLEAR | VERIFIED the door uses the shared `TypedTagPath` (`MobileNoteTags.swift:103-110`); its shape was not checked | check at design | Library & sidebar |
| PL-19e | Recovery rows' date-only stamps and clock slot; Block History's calm grammar | STILL OWED | VERIFIED zero phone refs to `stampTextDateOnly`, `clockSlot`, `savepointsExplainer`, `trayRevealKeptInLineage` (`Shared/RecoveryCopy.swift`, `Shared/BlockHistoryFace.swift`) | merge into VM-41 | Library & sidebar |
| PL-19f | `_italic_` in the markdown vocabulary | DISCHARGED by construction | VERIFIED row | close | Editor |
| PL-20 | The plaintext `.sqlite` export door | DUPLICATE OF VM-30 | VERIFIED zero phone refs to `Shared/PlaintextExportModel.swift` | merge into VM-30 | Import & export |
| PL-21-1 | Return as a structural act with the chip on | STILL OWED | VERIFIED the phone's Return is a text newline with list continuation (`MobileEditorTextView.swift:1015-1016`, `MobileMarkdownActs.swift:148-186`); no Write caller of `Shared/EditorBrain/TypedReturn.swift` | keep; one ticket with PL-31 and VX-806's mid-word rule | Editor |
| PL-21-2 | The "make every newline a block" door | STILL OWED | VERIFIED zero refs to `splitBlockAtNewlines` | keep | Editor |
| PL-21-3 | The divide sheet's three plain presets | STILL OWED | VERIFIED the phone divide is keep-on-top only (`Features/Write/MobileStructural.swift:161-177`); zero refs to `divideDuplicating` | keep | Editor |
| PL-21-4 | Caret-offset landing on every door into Write | STILL OWED — part: VM-10 keeps her caret per note; doors from read surfaces do not land at a block | VERIFIED `MobileEditorViewModel.swift:544-567` and PL-19c | merge with PL-19c | Editor |
| PL-21-5 | The editing-indicator preference on the phone's take surfaces | STILL OWED | INFERRED: zero phone refs to an editing-indicator setting | fold into the settings ticket | Settings & onboarding |
| PL-21-6 | The tray's leaving-explainer copy regression | STILL OWED | VERIFIED the phone renders the shrunk Mac sentence (`MobileNoteTray.swift:115-116`) over its stacked tray; `Shared/RecoveryCopy.swift:233-238` names it the phone's | keep (small) | Library & sidebar |
| PL-21-7 | A check: does iOS's `usageBoundsForTextContainer` ratchet like macOS 26's | UNCLEAR | no record of the check | fold into the device trace | Performance |
| PL-22a | The Write page's arrival scroll | DISCHARGED — VM-10 (PR #132) | VERIFIED `MobileEditorViewModel.swift:544-567` | close | Editor |
| PL-22b | Adopt the synced palette (four-parameter resolve) | STILL OWED | VERIFIED two-parameter `resolve(voice:dark:)` at `VariorumMobileApp.swift:57`, `MobileShellView.swift:179`, `MobileSettingsView.swift:76`, `MobileWriteView.swift:180`; zero refs to `PaletteTint` | keep, HIGH — her 11-12 visual direction is Study + sea-glass | Settings & onboarding |
| PL-22c | A face call on `receipt_style` | STILL OWED | VERIFIED `MobileProtectionDoors.swift:191` ("`receipt_style` has no phone consumer") | needs her call | App shell |
| PL-22d | 18h: created/edited stamps on rows and the masthead; title sort; a remembered direction; the "edited on this day" search | STILL OWED | VERIFIED zero refs to `TimeStampFace`, `DayBounds`; title sort refused (`MobileLibraryViewModel.swift:293-308`); direction fixed `.desc` (`:319`) | keep; merge with VM-22 and PL-35 | Library & sidebar |
| PL-22e | Re-walk a faced note across a dark toggle | UNCLEAR | a check; no record | fold into the device trace | Editor |
| PL-23-1 | A receipt naming where every block went after a cross-block edit | STILL OWED | VERIFIED `MobileStructural.swift:780-785` says the face is unbuilt | keep | Editor |
| PL-23-2 | A device walk of the cross-block gesture matrix | STILL OWED | INFERRED: no record of the walk | merge into VM-13 | Tests & tooling |
| PL-23-3 | The R-13u-4 capture face | DUPLICATE OF PL-27 | see PL-27 | merge | App shell |
| PL-23-4 | A call on showing "Undo New Block" in the phone's undo door | STILL OWED | UNCLEAR whether the door lists mints today | needs her call (small) | Editor |
| PL-23-5 | The tutorial teaches the retired duplicate divide | DUPLICATE OF VM-3 | see VM-3 | merge | Settings & onboarding |
| PL-24a | A paste-plain door (an edit-menu item) | STILL OWED | VERIFIED zero phone refs to `Shared/PlainPaste.swift` | keep | Editor |
| PL-24b | Look at the phone's ~30-character title room | STILL OWED | INFERRED: no record of the look; her 11-12 "the box looks awkward", "weirdly tiny font" | fold into the sizing pass | App shell |
| PL-24c | The landing-law pin on a real `UITextView` | STILL OWED | VERIFIED listed on VM-13 | merge into VM-13 | Tests & tooling |
| PL-24d | COPY ALL doors on the word screens | STALE — those screens were today's road, deleted at VX-329; the new words card has no Copy at all | VERIFIED `Features/Protection/MobileRoadFaces.swift:239-290` (title, lead, words, foot, button — no copy door); her VM-8 report "no Copy" | re-homed into VM-23/VM-28; close here | Castle & sync |
| PL-24e | The seam carves (empty-block backspace; texted-seam merge) | STILL OWED | VERIFIED `.carveEmptyBlock`/`.mergeTextedSeam` are undeclared on the phone (`MobileEditorViewModel.swift:1704-1712`) | keep; same item as PL-40a, VM-1, #111(c) | Editor |
| PL-25b | 17u's glyph rain | DISCHARGED — nothing owed | VERIFIED row | close | App shell |
| PL-25 | The comments panel's writing grammar; hoist `CommentComposition` | STILL OWED | VERIFIED `CommentComposition` is still Mac-local (zero `Shared/` hits); the phone sheet is its own (`MobileCommentsSheetView.swift`) | keep; one comments ticket with VM-18, VM-14, PL-46 (VX-179) | Editor |
| PL-26 | The `NoteCardFace` skim snippet on the phone's lists | STILL OWED | VERIFIED zero phone refs to `NoteCardFace`; Library rows carry no preview | keep, HIGH — her 11-12 "showing preview more lot apple notes" | Library & sidebar |
| PL-27 | Quick capture to R-13u-4: ⏎ files · ⇧⏎ paragraph · a many-paragraph box · the bulk hand-off · the text-preserving refusal | STILL OWED | VERIFIED the box still runs A5-2's ONE BLOCK with "⏎ opens it" (`Features/Shell/MobileQuickNote.swift:19-23,55`) and the boundary hold (`:72-73`) | keep, HIGH — the lost-prose class, and the surface of her lag report | App shell |
| PL-28a | Savepoint names lead Block History rows | DISCHARGED by construction | VERIFIED `SavepointRowFace.meta` at `MobileBlockHistorySheetView.swift:418` | close | Takes & Lenses |
| PL-28b | The commit door's optional name field and the rename door | STILL OWED | VERIFIED "Commit Take" calls `commitNow(blockID:)` with no name (`MobileBlockMenu.swift:194-196`); zero refs to `renameCommitPoint` | fold into VM-41 | Takes & Lenses |
| PL-29 | The restore confirm's real-cost line | STILL OWED | VERIFIED the phone confirm uses the static `VersionsPath.restoreConfirmDetail` (`MobileVersions.swift:341`); the cost form (`Shared/VersionsCopy.swift:199`) is unused there | keep (small) | Library & sidebar |
| PL-30 | Take-card acts composed as ONE list | UNCLEAR — guidance; the phone browser has its own buttons (`MobileTakesBrowserView.swift:157-166`) | VERIFIED buttons | guidance to the takes design; the tutorial half → VM-3 | Takes & Lenses |
| PL-31 | The empty-block Return chains | DUPLICATE OF PL-21-1 | as PL-21-1 | merge | Editor |
| PL-32 | The capture microsyntax at the phone's filing act | STILL OWED | VERIFIED zero phone refs to `Shared/CaptureMicrosyntax.swift` | merge into PL-27's ticket | App shell |
| PL-33 | The reading-position half of the phone's re-font | UNCLEAR — informational; the keep-your-place half exists, the blank-page half has no mechanism | row | no ticket | Editor |
| PL-34 | A `moveSpanToNewTake` door (candidate) | STILL OWED | VERIFIED zero refs | keep as a candidate in the takes umbrella | Takes & Lenses |
| PL-35 | The condensing word counter and the cycling stamp (candidate) | STILL OWED | VERIFIED no word counter on Write; zero `TimeStampFace` refs | merge with PL-22d | Editor |
| PL-36 | A Settings-search shape; the tutorial chapter-name fact (candidate) | STILL OWED | VERIFIED Settings is one short sheet | needs her call (likely not v1) | Settings & onboarding |
| PL-37 | The re-link Apple account door | STALE — no re-link exists on the new road | VERIFIED `vm-8-castle-catchup.md:170` | close | Castle & sync |
| PL-38a | The note-open rule (first open = start; re-open = where she left) | DISCHARGED — VM-10's session place memory | VERIFIED `MobileEditorViewModel.swift:544-567`; router-held `writePlaces` (`MobileWriteView.swift:202`) | close | Editor |
| PL-38b | The watched-lazy landing for a long note's Read | UNCLEAR — the phone has no per-note Read; its book Read is lazy (`MobileReadView.swift:13-17`) | VERIFIED | fold into the mode design | Books |
| PL-39-1 | The phone's find, to U7's decided rules | STILL OWED — part: a find exists (system navigator); U7's sameness rule and chosen-takes scope are unverified | VERIFIED `MobileEditorTextView.swift:946`, `MobileEditorViewModel.swift:1020-1028` | keep (a check plus small work) | Editor |
| PL-39-2/3 | The mode-switch caret rule; `arrival_flash` | STILL OWED — latent until the phone gains mode switching | VERIFIED zero refs to `ArrivalFlash`/`arrival_flash` | guidance to the mode design | Editor |
| PL-40a | Row 51's seam carves | DUPLICATE OF PL-24e | as PL-24e | merge | Editor |
| PL-40b | Row 49's lesson rewrite | DUPLICATE OF VM-3 | as VM-3 | merge | Settings & onboarding |
| PL-40c | The remaining `OperationError` switches and sealed/locked remainders — refusals that speak | STILL OWED | VERIFIED 69 `String(describing: error)` sites in the phone target (most: `MobileEditorViewModel.swift` 10, `MobileShelfViewModel.swift` 5) | merge with #195 MINOR 4 into one "refusals speak" ticket | App shell |
| PL-40d | F-4, the structural flight's keystroke fence | DUPLICATE OF VM-2 | as VM-2 | merge | Editor |
| PL-40e | Row 74's autosave-registry release | UNCLEAR | the 13l removal path landed in `Shared/AppSession` (handback §9.2); the phone's quick-note release was not checked | check, then close or keep in VM-12 | App shell |
| PL-41a | CRLF capture; seeding that honours a tombstone; #146's retirement | DISCHARGED in-phase | VERIFIED row | close (#146's ratify: §1e) | Settings & onboarding |
| PL-41b | Trace the leaving-savepoint twin (R-18k-6) on the phone's book faces | STILL OWED | INFERRED: no trace recorded | keep (trace only) | Books |
| PL-41c | The word screens' COPY ALL | STALE | as PL-24d | re-homed to VM-23/VM-28 | Castle & sync |
| PL-41d | The `one_block` CRLF write-back | STALE (likely) — the journal one-block seed is retired (VX-799); the capture rebuild supersedes it | INFERRED from AppSpec §7's setting note | close into PL-27 | App shell |
| PL-42 (VX-306) a | No Look inside, no Open Library door on the phone | DISCHARGED as ruled — P-VX306-U3-18 stands (PL-50(c)) | VERIFIED both rows | close | Castle & sync |
| PL-42 (VX-306) b | W-14: Terminal lowercases drafted titles and buttons | STILL OWED — her taste call | VERIFIED `chromeLabel` lowercases in Terminal (`VoiceTokens.swift:183-185`); the phone defaults to Terminal (`MobileVoicePreference.swift:31`) | needs her call — likely mooted by her Study direction | Settings & onboarding |
| PL-42 (VX-306) c | W-15: the words card said "on this Mac" | DISCHARGED — VX-329 | VERIFIED `Shared/Protection/ProtectionWords.swift:22-26` | close | Castle & sync |
| PL-42 (VX-306) d | Rule 3's reminder bar and the receipts' phone home | DISCHARGED (receipts — VM-8's P-VM8-8) / the band is VM-23's | VERIFIED `MobileShellView.swift:146-147,486` | close; band → VM-23 | Castle & sync |
| PL-42 (13i-a) a | The marker-10 install | DISCHARGED at the time — but see §0.1 (marker 15) | VERIFIED row | close | Castle & sync |
| PL-42 (13i-a) b | The wings, shelves and gatherings faces | DUPLICATE OF VM-6 | VERIFIED zero phone refs to `WingState`, `WingWords`, `BookcaseBoard` | merge | Books |
| PL-43a | Arrivals faces (the line and the judgment doors) | STILL OWED | VERIFIED zero phone refs to `seatArrival`, `dismissArrival` or any Arrivals face | merge with VM-42 | Books |
| PL-43b | The rule editor's face | STILL OWED | VERIFIED zero refs to `RuleEditing` | VM-6 | Books |
| PL-43c | The Pool tuck's face | STILL OWED — part: the bookless filter already reads the shared split's LOOSE class, so tucked notes are hidden there with no count and no door; the row's "the old way" is STALE | VERIFIED `MobileLibraryViewModel.swift:331-334`; `Sources/VariorumCore/Queries/ShelfQueries.swift:496-503` | VM-6 | Library & sidebar |
| PL-43d | The starred-gathering seed occasion | STILL OWED | VERIFIED zero refs to `Shared/StarredGatheringSeeder.swift` | VM-6 | Settings & onboarding |
| PL-43e | Bind/spawn doors | STILL OWED | VERIFIED zero refs to `convertSmartReadingToCurated` | VM-6 | Books |
| PL-44a | The membership choice sheet; Collecting sentences; Finish/Seal/Own doors; the outflow chooser; the gathering mint rule; two-choice delete and Duplicate; remove/release words; the badge family; the Trash's "and N notes" | STILL OWED | VERIFIED zero refs to `setReadingOwned`, `sealReading`, `setReadingOutflow`, `duplicateReading`; Finish exists (`MobileBookDetails.swift:114`) | VM-6 | Books |
| PL-44b | Two sealed-book sentences that still say "reopen" | STILL OWED | VERIFIED `Features/Shell/MobileTodayDoor.swift:66`, `Features/Write/MobileMembership.swift:184` | keep (small wording rider) | Books |
| PL-45 | The Bookcase as a list, the Book Panel, the wing switcher, per-item and bulk move/copy, per-wing Archived/Trash, honest counts, Star/Unstar words, the Welcome arrangement, the gathering Finish refusal's words | STILL OWED | VERIFIED zero refs to `WingState`, `BookcaseBoard`, `SampleLibraryWelcome`; "Pin to Shelf Top" still (`MobileShelfFaces.swift:109`) | VM-6, HIGH — her nine wings | Books |
| PL-46 (17y) | The pocket guide's furniture-fold facts entry | STILL OWED | INFERRED: no record | VM-6 4d / the tutorial ticket | Settings & onboarding |
| PL-46 (VX-179) | The deleted-comments fold and "Delete forever…" | STILL OWED — part: the fold and Restore exist; the purge door does not. The row's "no hand-placed comments face at all" is STALE | VERIFIED `MobileCommentsSheetView.swift:334-343`, `MobileComments.swift:224`; zero refs to `purgeBlockComment` | the comments ticket | Editor |
| PL-47 (13r) a | A crash-report opt-in face | STILL OWED | VERIFIED zero MetricKit refs | VM-9 | Settings & onboarding |
| PL-47 (13r) b | Whether the phone wants an in-app What's New | STILL OWED — her call | row | needs her call (VM-9) | Settings & onboarding |
| PL-47 (13i-e) | The archived-BOOKS group (Open · Unarchive); archive on ordinary books; "(archived)" marks; the Collecting pause sentence; the comes-back receipt | STILL OWED | VERIFIED archive exists only for the daily Journal (`MobileShelfFaces.swift:164-166`, `MobileShelfViewModel.swift:206-215`, `MobileBookDetails.swift:165-179`); zero refs to `unarchiveReading`, `archivedReadings` | VM-6 4d | Books |
| PL-47b (13o) | The search face | DUPLICATE OF PL-2 | as PL-2 | merge | Search |
| PL-48 (13x) | Whether the phone gets Send / Open-a-copy doors | STILL OWED — her call | row | needs her call | Castle & sync |
| PL-48 (VX-383) | Duplicate with Tags / without Tags | STILL OWED — "at her word" | VERIFIED zero `duplicateAsVersion` refs | needs her call | Library & sidebar |
| PL-49 (VX-83) | Search faces and a phone search lesson | DUPLICATE OF PL-2 | as PL-2 | merge | Search |
| PL-49 (VX-381) | The collect receipt's star and archived arms | DUPLICATE OF VM-21 | as VM-21 | merge | Books |
| PL-50 (VX-99) | The resume-door caption on `MobileProtectionSheet`/`MobilePostureSheets` (#204) | STALE — both sheets were deleted at VX-329 | VERIFIED absent from `Features/Protection/` | close | Castle & sync |
| PL-50 (VX-307) a | The calm first open: the words card into a band | DUPLICATE OF VM-23 | as VM-23 | merge | Castle & sync |
| PL-50 (VX-307) b | The crossings' faces | STILL OWED — part: entering crossings built at VM-8 (`MobileProtectionDoors.swift:546`: Use Castle, Replace All Keys); Use Standard and the leave arms held for F-PH-2 | VERIFIED | VM-28 | Castle & sync |
| PL-51 (13s-b) | The phone's own first-open shape | STILL OWED — design | row | onboarding design | Settings & onboarding |
| PL-51 (VX-329) a | Road faces, the pre-design face, sync at marker 14 | DISCHARGED — VM-8 | VERIFIED VM-8 record | close | Castle & sync |
| PL-51 (VX-329) b | F-PH-1's Mac-naming sentences; F-PH-2's leave sentence | DUPLICATE OF VM-28 (its kickoff riders) | VERIFIED VM-28 body | merge | Castle & sync |
| PL-52 | A Private-mark face on the phone; any phone MCP door | STILL OWED — her call | VERIFIED zero `ai_private` refs on the phone | needs her call | Library & sidebar |
| PL-53 (VX-143) | Block History's old row face vs the Mac's quiet ledger | DUPLICATE OF VM-41 (a deliberate divergence the history redesign ends) | VERIFIED `Shared/BlockHistoryFace.swift:271` | merge | Takes & Lenses |
| PL-53 (VX-168) | A lens filter on the phone's takes surface | STILL OWED — design | VERIFIED zero refs to `LensTakeFilter` | takes umbrella, her call | Takes & Lenses |
| PL-54 | VM-18, VM-19 | DUPLICATE OF VM-18 / VM-19 | — | merge | Editor |
| PL-55 | VM-16 (to land with or before this core), VM-17 | DUPLICATE OF VM-16 / VM-17 | — | merge | App shell |
| PL-56 | VM-20 | DUPLICATE OF VM-20 | — | merge | App shell |
| PL-57 | The first catch-up measured on her corpus; the resume live | DISCHARGED — VM-8 | VERIFIED `vm-8-castle-catchup.md:1085-1102` | close; the save time lives on VX-497 | Castle & sync |
| PL-58 | The first-round sheet, the check door, a live first run | DISCHARGED — VM-8 | VERIFIED VM-8 record | close | Castle & sync |
| PL-59 a | The pair follow face, the check door, the key doors' changed-elsewhere faces | DISCHARGED — VM-8 | VERIFIED VM-8 ledger rows 1–2 | close | Castle & sync |
| PL-59 b | VX-538's E6 card; the pocket guide's compromise page | DUPLICATE OF VM-28 | VERIFIED VM-28 body | merge | Castle & sync |
| PL-60 | VM-8's held items | DUPLICATE OF VM-28 | VERIFIED | merge | Castle & sync |
| PL-61 | The guide's "starred things sit above everything" is wrong for notes | STILL OWED | VERIFIED `Features/Tutorial/MobileTutorialSeeder.swift:291` | the tutorial ticket | Settings & onboarding |
| PL-62a | The gathering kind word in the phone's delete door and Trash labels | STILL OWED | VERIFIED `RecoveryCopy.rowKind(item)` without the gathering fact (`MobileTrashView.swift:258,273`) | keep (small) | Books |
| PL-62b | "Bring back as a take" in Block History | STILL OWED | VERIFIED zero `bringBackCommitAsTake` refs | merge into VM-41 | Takes & Lenses |
| PL-63 | A design pass on the phone's Starred page | STILL OWED — her task | VERIFIED `MobileStarredView.swift` unchanged in shape | design round | Library & sidebar |
| PL-64 | The Trash empty-flash; multi-select | DUPLICATE OF VM-33 / VM-31 | — | merge | Library & sidebar |
| PL-65 | No phone restore row for the Prince; the starter Journal's latch | DUPLICATE OF VM-29 / VM-35 | — | merge | Settings & onboarding |
| PL-66, PL-67 | Nothing owed (shared code delivered) | DISCHARGED | VERIFIED rows | close | Castle & sync |
| PL-68 | The Journal's fresh-mint New Entry; Delete beside Archive on the Journal; the date-shift door; the New Book sheet | STILL OWED | VERIFIED the Today door is create-or-open only (`MobileTodayDoor.swift:43`); `offersArchiveInsteadOfDelete` (`MobileShelfFaces.swift:164-166`); zero refs to `shiftEntryDate`, `newJournalEntry` | keep (a journal ticket) | Books |
| PL-69 | The Private mark and the AI trail on the phone | DUPLICATE OF PL-52 | — | merge | Library & sidebar |
| PL-70 | The History & Lineage surface | DUPLICATE OF VM-41 | — | merge | Takes & Lenses |
| PL-71 | The pin door, the Arrivals review, why-it-waits | DUPLICATE OF VM-42 | — | merge | Books |
| PL-72, PL-73 | Nothing owed (shared code delivered) | DISCHARGED | VERIFIED rows | close | Castle & sync |

### 1b. Open VM tickets (from `notes/TICKETS.md`; bodies read on Linear)

| Id | What is owed | Status today | Evidence | Disposition | Area |
|---|---|---|---|---|---|
| VM-1 | The hand-ins bundle: nine archive rows, plus the forked-brains hoist list | STILL OWED — routed, never closed. Forks still standing; seam carves, plain paste, copy-all and the Welcome arrangement unbuilt | VERIFIED `Features/Takes/MobileTakeStructureCopy.swift` exists; `MobileBlockSelectionCopy` at `MobileBlockList.swift:203`; seam arms at `MobileEditorViewModel.swift:1704` | dissolve into the new umbrellas; close VM-1 when every row has a home (its own rule) | Editor |
| VM-2 | The structural flight's keystroke fence — a mid-flight keystroke corrupts the store | STILL OWED | VERIFIED the latch is door-level only (`MobileStructural.swift:67-89`); the edit gate never reads `structuralInFlight` (`MobileMarkdownActs.swift:92,161,228`) | keep, HIGH — measured data corruption (VM-5 stability pass) | Editor |
| VM-3 | The tutorial teaches the retired duplicate-divide default | STILL OWED | VERIFIED `MobileTutorialSeeder.swift:596-599`; the pin is wrapped in `withKnownIssue` (`MobileTutorialWalkTests.swift:983`) | keep (small; her flagged beta risk) | Settings & onboarding |
| VM-4 | The catch-up umbrella, with its §5 held calls | STILL OWED as calls; STALE as a plan — VM-44 supersedes it | VERIFIED plan §5 (`notes/plans/vm-4-mobile-catch-up.md:341-351`) | close or re-point at VM-44's approval; carry §5's live calls (§1d) | App shell |
| VM-6 | The 13i family faces | STILL OWED | VERIFIED see PL-42…PL-47 | keep as the books family, split into umbrellas | Books |
| VM-7 | Editor & capture faces | STILL OWED — every listed member verified above | VERIFIED see PL-21/22/23/24/26/27/28/31/32/38/41 | split into umbrellas | Editor |
| VM-9 | Beta readiness: Dynamic Type + VoiceOver audit, TestFlight, crash opt-in, What's New, App Store | STILL OWED | VERIFIED chrome type is a fixed 11.5 pt in every voice (`VoiceTokens.swift:296,332,369,406`); only the editor body scales (`MobileEditorStyle.swift:107-125`) | keep; the type sizes move up into the visual pass | Settings & onboarding |
| VM-11 | Batch 8 revised: cadence/pruning rows, document settings, M14 measured | STILL OWED | VERIFIED Settings rows (`MobileSettingsView.swift:108-364`) | keep | Settings & onboarding |
| VM-12 | The leftover backlog: one editability authority, the silent keyboard drop, MINOR/NITs, "more info" → "info", "unseal" drift, the flush-caller sweep | STILL OWED | VERIFIED "more info" (`Features/Write/MobileReferences.swift:51`); "unseal" (`Shared/RecoveryCopy.swift:471`, `Shared/RecoveryActs.swift:201,206`) | keep as a debt umbrella | Editor |
| VM-13a | The device queue's Face ID walk | DISCHARGED — VM-8 | VERIFIED `vm-8-castle-catchup.md:1107-1108` | drop from the queue | Tests & tooling |
| VM-13b | The rest of the queue: the selection-defect experiment, the 100k perf and memory leg, M16 drag, D9 23 pt strip, the emoji-sheet overlap, the swipe band's pan, the landing-law walk | STILL OWED | INFERRED: no record of the window | keep; ride her plugged-in lag window | Tests & tooling |
| VM-13c | Retire the `MobileEditTrace` instrument at the queue's close | STILL OWED | VERIFIED the 632-line file and its Settings row (`MobileSettingsView.swift:284-285`) | keep with VM-13 | Tests & tooling |
| VM-14 | The comments placeholder is a hand-placed `UILabel` (Parked) | STILL OWED | VERIFIED `MobileCommentsSheetView.swift:32,77` | fold into the comments ticket | Editor |
| VM-15 | A sibling phone not yet followed into Castle (and its iCloud device backup) stays Apple-openable | STILL OWED | VERIFIED only the plan file is excluded from backup (`Shared/Protection/FilePlanStoreLeaf.swift:39`); the store and key file are not | keep, before mobile's launch | Castle & sync |
| VM-16 | The undo door mis-speaks a quiet press and its offered Redo can act on a different entry | STILL OWED | VERIFIED `Features/Write/MobileUndoDoor.swift:202,246` still call `undo(with:)`/`redo(with:)` | keep, Urgent on Linear | App shell |
| VM-17 | Probe: do the phone's fan badges pile at block 1 on long notes | STILL OWED — probe not run | INFERRED: no record | keep (probe first) | Editor |
| VM-18 | The comments sheet drops a half-typed comment on dismissal | STILL OWED — Needs Lillian | VERIFIED `MobileComments.swift` `close()` parks nothing; only a refused draft survives | needs her call on the phone's dismissal gestures | Editor |
| VM-19 | A stale first responder desyncs the editor in tests | STILL OWED | INFERRED (test-only) | keep | Tests & tooling |
| VM-20 | The undo warning says "It is saved first" where the Mac says "committed" | STILL OWED | VERIFIED `MobileUndoDoor.swift:285` | keep (wording rider) | App shell |
| VM-21 | Membership add lists archived gatherings; the collect receipt overclaims and names no star | STILL OWED | VERIFIED `MobileMembership.swift:132` has neither arm | keep (small) | Books |
| VM-22 | The exact past edit time reachable from every stamp | STILL OWED | VERIFIED the phone has no `TimeStampFace` stamps to extend | merge with PL-22d | Library & sidebar |
| VM-23 | A calm first open: retire the creation words card into a band | STILL OWED | VERIFIED `VariorumMobileApp.swift:203-204` still shows the card | keep (VM-28) | Castle & sync |
| VM-24 | The rescue-point caret test is red on main | STILL OWED — the canonical ticket | INFERRED from every phone gate since 10-25 | keep | Tests & tooling |
| VM-25 | Castle's "On this iPhone": no idle-lock dial, no Lock Library Now | STILL OWED | VERIFIED `MobileProtectionDoors.swift:634` | keep, HIGH — her 11-12 "a lock now button should be there like the mac" | Castle & sync |
| VM-26 | The Protection screen's keystone line has no phone home | STILL OWED | VERIFIED zero refs | keep (small) | Castle & sync |
| VM-27 | Two "Protection…" rows stacked in Settings | STILL OWED | VERIFIED `MobileSettingsView.swift:134-161` (the row's door plus the standing button) | keep (small) | Settings & onboarding |
| VM-28 | Umbrella: the words band, the E6 card, the guide chapters, F-PH-1/F-PH-2, the "saving…" sentence | STILL OWED | VERIFIED VM-28 body | keep, before mobile's launch | Castle & sync |
| VM-29 | The sample-library restore door | STILL OWED | VERIFIED the restore rows are DEBUG-only (`MobileSettingsView.swift:294-330`); the Jekyll exemption stands (`VariorumMobileTests/MobileStructuralTests.swift:1173-1184`). The title's "Jekyll" is half STALE: the phone no longer SEEDS Jekyll (R-17y-8) but receives it by sync, and the Prince has no phone restore row either | keep; widen the title to "seeded books" | Settings & onboarding |
| VM-30 | The plaintext export road | STILL OWED | VERIFIED zero `PlaintextExportModel` refs | keep | Import & export |
| VM-31 | Note-level multi-select | STILL OWED | VERIFIED no selection mode in the Library | keep (design first) | Library & sidebar |
| VM-32 | Install a phone build with VX-669's fix; run the Sherlock-deletes-stick round | STILL OWED | INFERRED: no phone install recorded since 2026-10-26 | keep, HIGH — fold in the marker-15 install (§0.1) | Castle & sync |
| VM-33 | The phone's Trash draws "empty" before its first value | STILL OWED | VERIFIED `MobileTrashView.swift:83-84` | keep (small) | Library & sidebar |
| VM-34, VM-36, VM-37, VM-38 | The same caret red, sighted again | DUPLICATE OF VM-24 (already Duplicate on Linear) | VERIFIED VM-24 body | none | Tests & tooling |
| VM-35 | The starter Journal's launch fact rides the signed-out-after-join road | STILL OWED | VERIFIED the Journal arm uses `storeWasEmptyAtLaunch` without the latch (`MobileFirstWriteFurniture.swift:245-253`) while the Prince arm uses it (`:291`) | keep (small) | Settings & onboarding |
| VM-39 | A phone Trash sweep door (empty blocks with no history) | STILL OWED | VERIFIED zero refs to `sweepEmptyTrashBlocks` | keep (Low) | Library & sidebar |
| VM-40 | A phone sweep for unused tags | STILL OWED | VERIFIED zero refs to `deleteUnusedTags` | keep (Low) | Settings & onboarding |
| VM-41 | No History & Lineage surface on the phone | STILL OWED | VERIFIED zero refs to `bringBackFromLineage`, `bringBackCommitAsTake` | keep; the history family | Takes & Lenses |
| VM-42 | The pin door and the Arrivals review | STILL OWED | VERIFIED zero refs to `setMembershipPinned` and Arrivals | keep; the books family | Books |
| VM-43 | The phone's restore doors don't insure the replaced words | STILL OWED | VERIFIED `MobileBlockHistory.swift:483` (`restoreCommit` without `insuringBuffer`) | keep (small; ruled) | Takes & Lenses |

### 1c. VX tickets that name the phone

| Id | What is owed | Status today | Evidence | Disposition | Area |
|---|---|---|---|---|---|
| VX-68 | The gate-less insertion watch row — "the first place to look on any typing-flicker report" | STILL OWED — a standing watch, both platforms | VERIFIED Linear body | keep; hand to the lag trace (her quick-entry lag report) | Editor |
| VX-672 | A phone sync round after a book purge takes minutes | STILL OWED — blocked on VM-32 | VERIFIED Linear body; `notes/plans/fixes/vx-500-sync-followups.md:262` | keep, High; profile on her phone after VM-32 | Castle & sync |
| VX-497 | A first catch-up's save holds the writer for minutes (worst on the phone) | STILL OWED — her "don't close it" | VERIFIED Linear body; VM-8 measured ≈ 4–5 min | keep; matters for her "synced between devices" launch goal | Performance |

### 1d. Plan and handoff obligations

| Id | What is owed | Status today | Evidence | Disposition | Area |
|---|---|---|---|---|---|
| VM-4 §1.7 / #199 | Hoist `FindReplaceGate`, `TakeClipboard`, `ThemeStore` to Shared | STILL OWED (3 of 4; `applyTypedPath` is done) | VERIFIED all three in `App/Variorum/Variorum/` only; `Shared/TypedTagPath.swift` exists | ride the feature each enables (replace, copy-all, palette) | Editor |
| VM-4 §4 Phase 2 | Pull-forwards VM-2, VM-3, VM-10 | STILL OWED (VM-2, VM-3) / DISCHARGED (VM-10) | as those rows | carry VM-2/VM-3 into wave 1 | Editor |
| VM-4 §5.5 (merge vocabulary) | Batch 9's proposal: (A) select-then-merge over block multi-select, (B) "Merge with Next" | STILL OWED — her call never made | VERIFIED only "Merge with Previous" (`MobileBlockMenu.swift:149`); no merge in the block list's bulk acts | needs her call | Editor |
| VM-4 §5.5 (chapter door) | The assign-to-chapter door's placement (batch 10) | UNCLEAR | not checked | check at design | Books |
| VM-4 §5.5 (others) | `receipt_style` on the phone; #139(f); What's New; the #189–#199 PROVISIONAL bundle | STILL OWED / STALE (#139(f)) | see PL-22c, PL-37, PL-47b, §1e | carry to the sitting | App shell |
| VM-5 handoff | Ratify #200(a–c), VM-10's three PROVISIONALs | STILL OWED — her ratify | VERIFIED no status line on #200 | needs her call | Editor |
| VM-5 handoff | Ratify #159's addendum, the unruled #192/#194/#195, two PROVISIONAL lines ("No bookless notes — every note is in a book." · "unlock it to keep writing") | STILL OWED | VERIFIED the first line still ships (`MobileListingFilters.swift:141`) | carry to her wording pass | App shell |
| VM-5 handoff | Remove the old `~/dev/variorum-mobile` worktree and the `mobile` branch | DISCHARGED | VERIFIED no such directory; no `mobile` branch (`git worktree list`) | close; but see §5 (two canon pointers still name it) | Tests & tooling |
| VM-8 handoff | The simulator secret helper; test-account cursor residue; VX-533's Air check | STILL OWED — hers, not the phone plan's | VERIFIED handoff items 2–4 | not mobile-plan scope | Tests & tooling |
| VM-8 record, bundle 7–9 | P-VM8-1…10 and the taste flags: hidden vs refusing follow-locked doors (P-VM8-9 (i)); the twice-told follow notice (R2-NIT-1); "your backups" on a backup-less phone (F-U2-H); the doorless posture line | STILL OWED — her ruling was "Stand as built until my wording pass." | VERIFIED `vm-8-castle-catchup.md:224-263,1124` | carry to her wording pass (with VM-28) | Castle & sync |
| Round-2 handback L-a…L-d | 13l's four (audit hoist, the Mac bar's text loss, migrations off main, autosave removal) | DISCHARGED — 13l | VERIFIED handoff §9.2 | close | Editor |
| Round-2 handback U-1…U-5, U-7 | 13u's five plus item 7 | DISCHARGED — 13u1 | VERIFIED handoff §2b table | close | Editor |
| Round-2 handback (M12) | KnownIssues M12 re-owned | DISCHARGED — owned by VX-68 | VERIFIED VX-68 title | close | Editor |
| Round-2 §3 row 1 | 4.5b's cold review | UNCLEAR — §2b says 13l's Fable review covered 4.5b; no explicit closing record found | INFERRED `mobile-round-2-orchestrator-handoff.md:725-731` | close as covered unless she objects | Tests & tooling |
| Round-2 §3 rows 2–8 | 4.5d fixes, 4.5a round 2, 4.5c, the stability pass, batches 5–10, the whole-round pass | DISCHARGED — run and merged at VM-5 | VERIFIED records exist (`notes/plans/mobile-batch-*-record.md`); `notes/plans/fixes/vm-5-the-catch-up-merge.md` | close | Editor |
| Round-2 §3 row 5 (4.5e) | Verify the `.opening` arm renders; autosave release at the quick note's reset | STILL OWED | VERIFIED listed on VM-12 | VM-12 | App shell |
| Round-2 §3 row 5b (4.6) | The quick note's second pass | DUPLICATE OF PL-27 | as PL-27 | merge | App shell |
| Round-2 batch 9 (e) | Text selection broken ("holding it down makes you scroll upwards") | STILL OWED — the one-minute experiment never ran | VERIFIED VM-13 lists it | keep, HIGH — a daily-use defect on the core surface | Editor |
| Round-2 §6.1 | M14, the 312 ms Read hitch at 100k | STILL OWED (measure only) | VERIFIED on VM-11 | VM-11 / the perf trace | Performance |
| Round-2 §6.2 | PR24: the marker's side and the margin tap shape | DUPLICATE OF PL-10 calls (i)(ii) | — | merge | Editor |
| Round-2 §6.3 / §11.5 | R27b starter-journal copy; batch 5's PROVISIONALs | DUPLICATE OF #194 | — | merge | Settings & onboarding |
| Round-2 §6.4, §6.5, §8.11, §8.14, §11.5 | D9 23 pt strip, M16, MAJOR 2 in her hands, Read memory at 100k | DUPLICATE OF VM-13b | — | merge | Tests & tooling |
| Round-2 §6.6 (F2) | Where a phone quick note lands (bookless vs Quicknotes) | STALE — the Mac's pad now lands in Home wearing the quicknote tag and Home's quicknotes gathering (SurfaceContracts.md:18, VX-841); the phone still mints bookless and untagged | VERIFIED the phone mints through `importPost` with no tag (`MobileQuickNote.swift:19-23,63`) | needs her call inside the capture rebuild (PL-27) | App shell |
| Round-2 §6.7 | A Release-side identity-boundary belt | STILL OWED — her risk call; both platforms now carry the DEBUG oracle | VERIFIED handoff §9.2 (L-a landed) | needs her call (low) | Editor |
| Round-2 §6.8–§6.10 | The gap-fence narrowing and its boundaries | DISCHARGED — 13u1 U-3 fences gaps at the root and names the cause | VERIFIED handoff §2b U-3 | close | Editor |
| Round-2 §8.12, §8.13 | The boundary hold's residual cost; the caret collapsing after a hold | STALE — both are consequences of A5-2, which R-13u-4 replaces | VERIFIED PL-27 | close into PL-27 | App shell |
| Round-2 §8.15 | R30: her phone runs three fixed bugs | DISCHARGED — installs since (VM-5, VM-10, VM-8) | VERIFIED VM-5 and VM-8 handoffs | close | Tests & tooling |
| Round-2 §11.5 | R24 "more info" → "info" | DUPLICATE OF VM-12 | — | merge | Editor |

### 1e. QUESTIONS entries that concern the phone

| Id | What is owed | Status today | Evidence | Disposition | Area |
|---|---|---|---|---|---|
| #111(c) | The iPhone has no seam carves | DUPLICATE OF PL-24e | — | merge | Editor |
| #127(b) | — (her words: the microsyntax "is more for quicknotes on the phone") | DUPLICATE OF PL-32 | VERIFIED `notes/QUESTIONS.md:1576` | merge | App shell |
| #139(f) | Whether the phone gets the re-link door | STALE — re-link retired with today's road | VERIFIED `vm-8-castle-catchup.md:170` | close | Castle & sync |
| #146 | The signed-out-first phone's sample book retires at sign-in (PROVISIONAL, built at 18o) | UNCLEAR — no ratify status found | VERIFIED `notes/QUESTIONS.md:1906-1911` | carry to the sitting | Castle & sync |
| #155(ii) | A phone restore row for takemania | DUPLICATE OF VM-29 | VERIFIED the exemption stands (`MobileStructuralTests.swift:1173-1184`) | merge | Settings & onboarding |
| #178 | The Welcome arrangement's asymmetric dedupe | DUPLICATE OF VM-6 (4d) | — | merge | Books |
| #189 · #190 · #191 · #197 · #198 | Two rooms; kind filters; the shelf's two refinements; books as rows; All = books + notes | DISCHARGED — built (batch 5, 6c, the filter batch) | VERIFIED `MobileListingFilters.swift`, `MobileArchiveView.swift` exist | close | Library & sidebar |
| #192 | Block History's one-take sentence | STILL OWED — held to the copy pass | VERIFIED entry | carry to the wording pass | Takes & Lenses |
| #193 | B1: her real Journal arriving beside the starter one after a later sign-in | DISCHARGED — R-pre13u-1 (seed at first write behind the account gate); the residual is VM-35 | VERIFIED PL-17(a) | close; VM-35 carries the rest | Settings & onboarding |
| #194 | Batch 5's taste PROVISIONALs (incl. the box's 11.5 pt type; collapse on blur) | STILL OWED | VERIFIED entry | carry into the visual pass (her "tiny font") | App shell |
| #195 MINOR 3 | `MobileEditorStyle.voice` is an unsynchronised mutable global | STILL OWED | VERIFIED `MobileEditorStyle.swift:48` (`nonisolated(unsafe)`) | ride the palette/ThemeStore work | Tests & tooling |
| #195 MINOR 4 | Refusals with ten homes and raw dumps | STILL OWED | VERIFIED 69 raw `String(describing: error)` sites | merge with PL-40c | App shell |
| #196 | The `main` iOS build break | DISCHARGED — fixed 2026-08-30 | VERIFIED entry | close | Tests & tooling |
| #199 | Four hoists deferred to after 13u | STILL OWED (3 of 4) | as VM-4 §1.7 | merge | Editor |
| #200 | VM-10's three PROVISIONALs | STILL OWED — her ratify | as VM-5 handoff | carry | Editor |
| #204 | VX-99's phone caption | STALE — the sheets are gone | as PL-50 (VX-99) | close | Castle & sync |
| #234 W-14 / W-15 | Lowercase chrome; "on this Mac" | STILL OWED (W-14) / DISCHARGED (W-15) | as PL-42 (VX-306) b/c | as those rows | Settings & onboarding |
| #242 | VM-8's bundle | STILL OWED — "Stand as built until my wording pass." | as §1d | carry | Castle & sync |
| #274 addendum 2 | Wire `insuringBuffer` on the phone | DUPLICATE OF VM-43 | VERIFIED VM-43 body | merge | Takes & Lenses |

---

## 2. (a) Her standing mobile rulings any new plan must respect (verbatim, with sources)

**What the app is.**
- *"perhaps I didn't make it clear enough to the original section, but the variorum mobile app should be a complete,
  comprehensive app and solution. it should feel basically just as capable as the mac app"* · *"this will be my daily
  driver complimentary app (like apple notes on the phone v. computer) so it can't be a very lobotomized version
  without me missing functionality."* — `notes/plans/mobile-app-plan.md:5827-5833` (CoreDescription pillar 8).
- *"if it exists on the mac app and is your information you should be able to see that it exists"* — MobileSoul §4.3.
- *"I do not want the mobile app to choke even on 100k words"* — MobileSoul §2.
- *"some people will be phone only users and they should get to experience it."* — R-pre13u-8 (MobileSoul PL-17).
- *"make sure that the mobile plan is thoroughly updated with what it'll need too in terms of autominting on keychain,
  setting passphrase, etc. some people will be mobile only users."* — 13p Batch-1 rider (MobileSoul PL-15).
- *"i think i will include takes on mobile"* — R58 (`mobile-app-plan.md:6102`).

**The exclusions.**
- MobileSoul §4.5, verbatim: *"**Exclusion, ruled and recorded** — Compare · the scraps drag-into-note door ·
  sticky-note/canvas editing · workspace & windowing · two-pane outline · expand-all-fans · side-by-side reference
  panel · ceremonies · iPad (PERMANENT: portrait-locked iPhone; declaring iPad capability forbids portrait-only — never
  declare it)."*
- Her gate words behind it: *"compare, snippets (I can't think of how to easily do this on mobile without it being a
  mess), and the sticky note style of editing."* — `mobile-app-plan.md:5836-5838`.
- Ceremonies: *"there is probably a workaround there the same way I chose a workaround for divide and then realized
  that it should be the normal default setting for mac - if it's too complicated for mobile, there should probably be
  an easier way of doing it, even if it's a bit of a workaround."* — `mobile-app-plan.md:5843-5848`.
- The complexity test (2026-08-09): *"Truthfully, I thought merge and divide were already overly fiddly on the mac app
  and I think mobile is good for exposing complexity that can't survive a simplified UI, because that's a sign it may
  be too complex period."* — MobileSoul §4.
- **Compare REOPENED for after v1 (2026-11-12):** *"having thought about it I would like to have a compare mode, maybe
  with the notes as different tabs that you can swipe between and still have the notes line up  block by block? that's
  just one idea on it and again, probably won't even be in v1 of the mobile app"* — `her-words.md`. §4.5 must record
  the reversal at approval.

**The look and the voice.**
- *"keep both with its own switch"* — LK2, the phone-local voice (`Theme/MobileVoicePreference.swift:5-6`).
- *"the overall look of the app is fine aside from how everything is weirdly small and spaced, but honestly, just use
  the mac app as your visual direction. the study mode especially. the sea greeen theme"* — `her-words.md` (2026-11-12).
  This leans against the phone's Terminal default and its palette-blind resolve (PL-22b).
- *"the phone hasn't been getting much design attention."* — PL-63.

**Capture and the quick note.**
- R5: *"in the 'quick note' box on the home screen, if the user just closes the app, their note should still be saved!
  it should have generous instant saving so that even if they forget to hit enter or press the button to edit it fully,
  it's still saved and it should show a little icon when saved."* — `MobileQuickNote.swift:5-10`.
- *"complete disaster, lost prose class of bug. we need full multi line editing clearly or some other solution because
  this was not it."* and (on swipe-away) *"maybe it needs to stay in that field for like three minutes when you swipe
  away, editable in that field… at the very least, a link to the one that was just created should pop up."* —
  round-2 handoff §3 row 5b.
- *"4.6 is going to happen after 13u, so update it to say it won't need a design sitting, the mac will have decided
  it."* — the same row. (R-13u-4 is that decision: ⏎ files, ⇧⏎ paragraph — PL-23(3), "never to be re-decided".)
- *"this is more for quicknotes on the phone"* — the capture microsyntax (`notes/QUESTIONS.md:1576`, #127(b)).
- *"the box should be one line until you click into it"* · *"the shelf should be bounded so it always has a decent
  amount of room to write"* — #191.

**Editing.**
- *"showing empty space should be allowed if you scroll there but it shouldn't be forced."* — VM-10
  (`vm-4-mobile-catch-up.md:75-77`).
- *"i want it easy to access."* (structural undo and redo in the ⋯ menu) · *"i also only see merge with previous rather
  than a multi merge option? or do we need to add multi merge on mobile still? or a select and then merge? idk, let's
  think about that three dots menu a little more."* · *"holding it down makes you scroll upwards, the exact opposite."* —
  round-2 handoff §3 row 7b.
- On the Mac (the rule the phone's VM-18 mirrors): *"yes, clicking away should save your half typed comment on a
  draft."* — VX-257; the phone's dismissal shape is hers (VM-18).
- *"Ratify + wire the phone."* — insured restores, #274 addendum 2 (VM-43).

**Navigation, books, the Library.**
- *"it's killing me."* (a swipe between shelf and library) · *"I don't like where it appears above the shelf, I think
  it's awkward placing."* (starred) · *"add smart book of starred notes to the 13i phase and don't build it yourself.
  however, DO build a different way to see starred notes on the homescreen"* · New Note/New Chapter in a book *"which
  the mac up does have."* — round-2 handoff §3 row 7c.
- *"I want this option: Two rooms."* — #189.
- *"Archived is a comparatively rare option, and it needs the same filters that the regular library has… which is
  more important because it's where you see everything"* — #190.
- *"All should be a book + notes union - otherwise it just doesn't make sense."* — #198.
- *"the phone will also have archive and delete separated and on mimicking the surfaces that the mac has decided on,
  in some way that works for mobile (make a note that it can have a design session and propose different designs to me
  with html when the time comes)"* — PL-14(b).
- *"the mac app ruled that the UI would deny duplicate book namings but it wouldn't cause a deeper issue… it can be UI
  gated on the rename area, but it's not a serious bug or issue."* — PL-10(b).
- *"I have 9, so UI options should work well with many. a quick swipe between them and also a dropdown option would be
  nice."* — wings, `her-words.md`.
- *"showing preview more lot apple notes so i know what each note is."* — `her-words.md`.

**Protection.**
- 13p's phone re-lock, as quoted in the code: *"re-lock on background as the phone's re-lock dial + the manual Lock
  Now act in demanded modes (the hand-someone-your-phone case — a REAL boundary here, key material dropped)"* —
  `Features/Protection/MobileRelock.swift:5-9`. (PL-15(g) words the same idea as the plan's; treat this as quoted, not
  confirmed verbatim.)
- **Now in tension with:** *"app staying unlocked for a few minutes damn."* · *"fully closing the app rather than just
  backgrounding it should make the library lock automatically though."* · *"and a lock now button should be there like
  the mac."* — `her-words.md` (2026-11-12). Her ruling, checked against CastleRules at design.
- *"Stand as built until my wording pass."* — the VM-8 provisionals and taste flags.
- *"mint an umbrella ticket for this and you can mark it as before mobile's launch, but tbh we're kinda far from
  releasing mobile so we won't do it right now"* — VM-28.
- *"honestly i don't think we'll fix it right now but don't close it"* — VX-497.
- *"file the double protections as a bug not a taste call"* — VM-27.

**Process.**
- *"i agree that those four hoists should just be deferred to the post 13u merge - seems cleaner that way."* — #199.
- *"we shouldn't start writing code (unless you can't run the app because something is broken…)"* and the cast and
  umbrella/wave shape — `her-words.md` (VM-44).
- *"none, make note of all of them but only i use the phone app rn"* — VM-8's riders. (That premise ends when the phone
  ships to others; VM-15, VM-16 and VM-27 were declined on it.)

---

## 3. (b) One obligation, many names

| The obligation | The names it goes by |
|---|---|
| The capture rebuild (R-13u-4) | PL-27 · PL-23(3) · PL-32 (microsyntax at the same hand-off) · PL-41(d) (the CRLF write-back) · VM-7's lead · round-2 batch 4.6 · round-2 §8.12/§8.13 · round-2 §6.6 F2 (where it lands — now also VX-841's Home quicknote rule) · #127(b) |
| The seam carves | PL-24(e) · PL-40 "row 51" · VM-1 "missing seam carves" · VM-7 · #111(c) · round-2 4.5c "the unwired A7/#34 carves" |
| The tutorial's retired divide lesson | VM-3 ("row 48") · PL-23(5) ("row 64") · PL-30 · PL-40 ("row 49") — **three different KnownIssues row numbers for one item** |
| The keystroke fence | VM-2 ("row 95") · PL-40 F-4 · PL-45's "structural-flight keystroke fence" · VM-5 stability pass MAJOR 1 |
| Copy all takes | PL-1 · PL-10(c) · VM-7 · #199 (`TakeClipboard`) · round-2 R11 · VM-5 whole-round observation |
| COPY ALL on the words screens | PL-24(d) · PL-41 · VM-1 "copy-all doors" · VM-7 — and now VM-23/VM-28 (the new card has no Copy) |
| Paste plain | PL-24(a) · VM-1 · VM-7 |
| Find and replace | PL-1 · PL-39(1) · #199 (`FindReplaceGate`) · round-2 batch 7's PR21 |
| Whole-library search | PL-2 · PL-47b · PL-49 (VX-83) · VX-819 (unrecorded) |
| The synced palette | PL-22 (18g) · VM-7 · #199 (`ThemeStore`) · #195 MINOR 3 (its structural half) · her 11-12 "sea greeen theme" · VX-292/VX-710's sea-glass default (unrecorded) |
| Stamps, sort and day search | PL-22 (18h) · PL-35 · VM-22 · VM-7 |
| `receipt_style` on the phone | PL-22 (18i) · VM-4 §5.5 · VM-7 · P-VM8-8 |
| Wings, shelves, books | PL-4 · PL-42 (13i-a)(b) · PL-45 · VM-6 4a · her "no different wings (!!)" |
| Arrivals | PL-43(a) · PL-44's "Arrivals arms" · PL-71 · VM-42 · VM-6 4b |
| Book archive | PL-47 (13i-e) · VM-6 4d · PL-68 (Delete beside Archive) |
| Star words and the Starred page | PL-45 (Pin → Star) · PL-61 · PL-63 |
| History and lineage | VM-41 · PL-70 · PL-62(b) · PL-28(b) · PL-53 (VX-143) · PL-19(e) · VM-43 · #274 add. 2 |
| Comments | PL-25 · VM-18 · PL-54 · VM-14 · PL-46 (VX-179) · PL-10 calls (i)(ii) · round-2 §6.2 PR24 |
| Lock Now and the idle dial | VM-25 · PL-15(g) (built, then deleted at VX-329) · her 11-12 lock words |
| The sample-book restore door | PL-17 · PL-18 · VM-29 · PL-65 (the Prince) · #155(ii) · VM-8's old scope |
| Plaintext export | PL-20 · PL-13 residue · VM-30 · P-VM8-4 |
| Note multi-select | PL-13(e) · VM-31 · PL-64 · VM-8's old scope |
| The device queue | VM-13 · PL-15 (perf leg) · PL-23(2) · PL-24(c) · round-2 §6.4/§6.5/§8.11/§8.14/§11.5 · batch 9(e) (selection) |
| Return as structure | PL-21(1) · PL-31 · VX-806 (the Mac's mid-word rule, unrecorded for the phone) |
| Forked brains | VM-1's list · #199 · #195 · MobileSoul §3 |
| Refusals that speak | PL-40(c) · #195 MINOR 4 · VM-12's "refusal-copy homes" |
| The caret test's red | VM-24 · VM-34 · VM-36 · VM-37 · VM-38 |
| The phone build on her device | VM-32 · VX-672 (blocked by it) · §0.1's marker-15 install (unrecorded) |
| Snippets | PL-18(c) · her gate exclusion "snippets" · MobileSoul §4.3's "scraps viewing" — **these disagree: the ledger owes a renamed, grouped scraps room while her gate words say "not replicated"; her call** |

---

## 4. (c) Mac work with no ledger row

The ledger's dense run ends at PL-73 (VX-849, 2026-11-09). These efforts have no row, though they shipped something
the phone either lacks or now diverges from. Status of each: INFERRED from the closeout paragraphs in
`notes/PhaseCloseoutArchive.md` and the fix records, plus the phone greps cited.

1. **Marker 15 (VX-808's v1_37, deployed at the Nov 7–8 sitting).** PL-71 says the bump "binds the phone's track";
   nothing tells anyone to put a marker-15 build on her phone. See §0.1.
2. **VX-292 (+ VX-559, VX-710; closed 2026-10-30) — onboarding.** Fresh stores open in Study with the sea-glass
   palette; a store that never picked a palette now wears sea-glass; the calm first open with the welcome card band.
   Its closeout says "nothing mobile-visible", true of the code, but the phone now diverges: Terminal default
   (`MobileVoicePreference.swift:13-14,31`) and no palette at all (PL-22b). The tour is Mac-only by design.
3. **13n-a (2026-10-09) — the Variorum document format.** Import (a file → a Pool note, a folder → a book) and Copy
   full text in the fan-carrying format. The phone has no import door (zero refs to `importDocument`/`DocumentImport`),
   and its Copy writes the `.md` export projection (`MobileNoteClipboard.swift:9-17`), not the document format. No row.
4. **VX-828 (2026-11-05) — editor & shell QoL.** VM-39/VM-40 were minted, but no ledger row; VX-806's mid-word Return
   cut lives in the shared `TypedReturn`, which the phone never calls (rides PL-21-1).
5. **VX-648 (2026-10-28).** PL-61 records only the star cap. The run's Move to Wing / Copy to Wing doors, the
   wing-label door and ⌘↑/⌘↓ book stepping have no row (the wing doors fold into VM-6; book stepping is a design
   question on the phone).
6. **VX-724 (2026-11-01) — the book's bottom position bar** ("note 7 of 30 · chapter", with counts). No row; the phone
   book screen's equivalent was not checked.
7. **VX-819 (2026-11-06) — the search umbrella** (the Blocks facet, `+ commits`, the order door, the sidebar search
   field). No row; covered in spirit by PL-2/PL-47b because the phone has no body search at all.
8. **VX-914 (2026-11-08).** Its closeout's MOBILE PARITY line says VX-909's sync-pause pair is phone-visible through
   `Shared/` — **a line was written but no PL row**. VX-911 (⌘⏎ files the new-note box without opening it) is capture
   behavior the phone's rebuilt capture face should weigh.
9. **VX-915 (2026-11-09) — the recents sweep.** VX-841 (the pad lands in Home with the quicknote tag; a one-capture wing
   pick), VX-934 (`ai_marks`, `ownership_badges` as synced switches), VX-782 (a callout keeps the prose measure). Closeout:
   "nothing mobile-visible" — true of rendering, but the phone's quick note lands bookless and untagged (§1d F2), and
   its callout emoji sits inside the measure (`MobileBlockDecor.swift:15-21`).
10. **VX-348 (2026-10-18).** VM-22 was born from it; no ledger row (a bookkeeping gap only).
11. **Efforts whose closeouts say "nothing mobile-visible" and where I found no phone-relevant capability:** VX-309,
    VX-382, VX-548, VX-439, VX-562, VX-620, VX-623, VX-601, VX-677, VX-736 (Mac-only tour cards), VX-771, VX-781,
    VX-853, VX-809 (MCP), VX-912, VX-913, VX-926. VX-283 and VX-601 were skimmed only (UNCLEAR).

**Found while verifying, recorded nowhere I read:** the phone's Library shows only the newest 200 notes, with no paging
(`MobileLibraryViewModel.swift:77,316-320`, `observeLibrary(… limit: listingLimit)`). On her large corpus this alone can
make "it's hard to find items in the library" true. VERIFIED code; INFERRED that it is unrecorded.

---

## 5. Ledger hygiene (for whoever rewrites §6)

- **Duplicate PL numbers:** PL-42 (VX-306; 13i-a), PL-46 (17y; VX-179), PL-47 (13r; VX-201) plus PL-47b, PL-48 (13x;
  VX-383), PL-49 (VX-83; VX-381), PL-50 (VX-99; VX-307), PL-51 (13s-b; VX-329), PL-53 (VX-143; VX-168). The PL-25/25b
  precedent was not kept up.
- **Rows PL-43…PL-73 sit under §7 ("How to run mobile phases") as bullets**, out of order, not in the §6 table; and the
  13r PL-47 bullet has 13i-e's archive row fused into it mid-sentence.
- **Stale pointers in canon:** MobileSoul §7 still says to run mobile phases from the `~/dev/variorum-mobile` worktree
  against `notes/plans/mobile-parity-round.md`, and CLAUDE.md's Environment section still names "mobile worktree
  `~/dev/variorum-mobile` (branch `mobile`)". Both retired at VM-5 (VERIFIED: no directory, no branch). A doc fix, at
  her word.
- **Status cells that lag the tree:** PL-10 and PL-11 still read "waiting on the next mobile session" for parts that
  shipped; PL-19 says the phone has no Lenses (it does); PL-43(c) says the phone lists loose notes "the old way" (it
  reads the shared split); PL-46 (VX-179) says the phone has no comments face (it has one, with a deleted fold).

---

## 6. Counts

Rows by status across §1a–§1e (230 rows; a source item split into parts counts once per sub-row; a "STILL OWED — part"
row counts as STILL OWED). Counted mechanically from the status column.

| Status | §1a ledger | §1b VM | §1c VX | §1d plans | §1e QUESTIONS | Total |
|---|---|---|---|---|---|---|
| STILL OWED | 67 | 37 | 3 | 12 | 8 | **127** |
| DISCHARGED | 30 | 1 | 0 | 7 | 3 | **41** |
| STALE | 11 | 0 | 0 | 2 | 2 | **15** |
| DUPLICATE OF … | 26 | 1 | 0 | 5 | 5 | **37** |
| UNCLEAR | 7 | 0 | 0 | 2 | 1 | **10** |

About 17 of the 127 STILL OWED rows are her calls or her wording pass rather than build work (PL-10 calls, PL-18c,
PL-22c, PL-23-4, PL-36, PL-42 b, PL-47 b, PL-48 ×2, PL-52, PL-53 (VX-168), VM-18, the merge vocabulary, #200, the VM-5
ratify bundle, the VM-8 bundle, the Release-side belt). Every VM ticket open on the board is still owed except VM-13's
Face ID walk; none was found silently done.
