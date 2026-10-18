# VX-348 — Run: Pre-launch bug sweep (her running list)

**STATUS: IN PROGRESS — kicked off 2026-10-18 (architect shape; Fable orchestrates at her launch, superseding the
plan's Opus-orchestrates default for this run). Branch `vx-348-prelaunch-sweep`, worktree `~/dev/variorum-vx-348`,
in-flight row added. The kickoff sitting ran (below); the rest of the run needs nothing from her.**

## KICKOFF SITTING (2026-10-18) — VX-351's design pass, her rulings verbatim

Her launch message (the frame): *"We can start with a design pass on the question of how to show the time - I'd like
to get that resolved first. The coordinator will handle your needs wrt stage releases. the sync slot is claimed +
busy, so if anything looks like it needs that, it'll have to just wait and be deferred."*

The orchestrator's grounding brought to the sitting: `TimeStampFace` (Domain) is the one brain — glances read
`today 1:33 AM` · `yesterday` · `Sep 9` · `Sep 9, 2025` (time only for today, by design); the whole-fact hover
(`Edited Oct 13, 2026, 4:02 PM`) and the click-flip (edited↔created) already live on three surfaces (List rows,
cards, the note masthead). The two gaps: `LibraryInfoPanel.factsLine` prints the RAW DAY KEY (`edited 2026-10-13`,
via `JournalDay.dayString` — the drift copy) and `NoteBox.stampsLine` is date-only; neither hovers. Other speakers
(Timeline, search answer sheet, book Arrivals/Archived lines, MCP grant picker) each word time their own way, no
hover.

- **R-VX348-1 (mechanism):** she picked **"Hover everywhere"** (the recommended option, selected with its preview):
  glances stay calm (today 1:33 AM · yesterday · Sep 9); every stamp speaker gains the existing whole-fact hover;
  the two gaps join `TimeStampFace`. No new UI, no setting in this run.
- **R-VX348-2 (the stamp-form setting):** her words verbatim: *"synced sounds good but we should mint another
  ticket since the sync stage is currently occupied"* — the setting (simplified · long · short glance forms) is
  DEFERRED to its own ticket, synced when built. Minted at this sitting as **VX-389** (Parked at her word, Low,
  Improvement · Confirmed · Library & sidebar).
  *(Orchestrator's note, recorded for honesty: a new `setting` key is an ordinary synced key-value row — no
  migration, no `Sources/VariorumCore/Sync/` line, no lockstep — so it would not strictly need the occupied slot;
  her deferral stands as ruled, and this note rides the ticket so the premise is visible at her next triage.)*
- **R-VX348-3 (surfaces):** **"All speakers"** — the two gaps move onto `TimeStampFace` with hover, and the
  Timeline, search answer sheet, book Arrivals/Archived lines and MCP grant picker gain the same hover. One rule
  everywhere a stamp speaks.
- **R-VX348-4 (the phone):** **"VM ticket, later"** — minted at this sitting as **VM-22** (Low); the shared Domain
  brain changes ride free; this Mac sweep touches no mobile face.

**VX-351's build shape under these rulings (lands in U4):** route the info panel's facts line and the note box's
stamps line through `TimeStampFace` (one wording rule — the raw-day-key drift closes); give every stamp speaker the
whole-fact hover via `TimeStampFace.tooltip`; no glance-form change, no setting, no click-flip change. Pins:
red-on-old for the info panel's wording (the raw key is the old behavior) and for each speaker's hover presence
where a pin can read it; the walk covers the rest.

## HER OVERNIGHT MANDATE (2026-10-18, right after the sitting — verbatim)

*"yes, let's bring these in: VX-176 (segmented controls draw system blue in dark Terminal — the exact controls row
VX-350 reworks) and VX-355 (the Pool has no bottom bar for receipts — this looks like the same fix as VX-385's
quiet-receipt line; if so it closes for free and I'd mark it). also, I want you to run ruling provisionally
overnight. I'm going to sleep. You can merge to main when you're done - if other sessions finish first that's fine,
merge in the order you finish in. if you finish, I want you to leave me with a handoff AND separately a completed
block of everything that was done (including if new items were minted during the run) in this sort of format:"* —
followed by her checklist format (a numbered run heading, the members as `- [ ]` lines grouped **Her running list ·
Today's road (folded in 2026-10-18) · Riders**). The closeout writes that block with every member ticked and any
run-minted items included, SEPARATE from the handoff.

So: **VX-176 joins U3** (its code is the controls row U3 reworks) and **VX-355 joins U4** (expected the same fix as
VX-385 — if the one `QuietReceiptLine` at the Pool's foot proves both tickets' cases, VX-355 closes with it and the
record says so). ELEVEN members now. Rule PROVISIONALLY overnight and bundle for QUESTIONS at the merge; the merge
runs at this run's own finish, serialized with VX-381/VX-382 in whatever order the runs finish.

**HER RELEASE WORD (03:3x MDT, given to the coordinator and then CONFIRMED by her directly in this session — her
words verbatim: *"I told the coordinator but I want the LAST of you current 3 sessions (381, 382, 348) that merges
to mint a release. I also have a castle effort live but it's fine if the release carries it and it won't be doing
the release, so that might merge in but doesn't need to be considered one of the efforts for release purposes."*):** the Pro stays
fully available overnight; VX-381, VX-382 and VX-348 merge to main in whatever order they finish; **ONLY THE LAST of
the three to merge mints ONE release — 0.9.8 — covering all three** (VX-378 never mints; a release may carry it if
merged by then). The mechanics, per the coordinator: before the merge ask, this run lands its own section in
`ReleaseNotes-0.9.8.md` on this branch (one-line bullets, the 10-16 precedent) so the last merger's notes cover all
three without reaching into another branch; merge asks carry branch, tested tree, tip (must contain main
`fdce74de3`); first/second merger = merge + closeout only, NO bump, NO refresh; the LAST merger — told so explicitly
by the coordinator — mints 0.9.8 (release.sh: DMG, appcast, site deploy) plus the folded /Applications refresh under
a coordinator-GO'd stage window with the full rule card (A1 safety copy first, zero-instance checks, codesign
verify). This is the standing runway rule (ONE release when the last run of a set is done) now carrying her explicit
word for this set.

**The trailer slip is FIXED at her word:** she ran the force-push herself — main `d35b07515` → `fdce74de3`,
identical tree, the message without the trailer. (History rewrite authorized by the author in person; the lease
pinned exactly the trailer commit.)

*(The original pre-kickoff banner follows, kept as written.)*

**STATUS AT WRITING: READY FOR KICKOFF — written 2026-10-18 at her word ("I want to kick that sweep off soon / now so I'd like to
have it all ready"); the run ticket is VX-348 itself (Todo), its branch and worktree are minted by ITS orchestrator at
kickoff.** Members (sub-issues of VX-348), nine: **VX-347 · VX-351 · VX-350 · VX-357 · VX-349** (her running list,
filed 2026-10-14/15) · **VX-338 · VX-339** (the "today's road" pair, folded in 2026-10-18 at her word) · **VX-384 ·
VX-385** (riders born from VX-383's walk, Pre-launch at her word 2026-10-18). Project: v1 release readiness.

**Cast (her word 2026-10-18): a Fable cold review over the WHOLE sweep's diff** — `fable-reviewer` at xhigh, a fresh
one per ladder round — **and VX-338 named for Fable in particular** (it deletes backup files). `opus-implementer` at
xhigh builds, one unit per fresh session. Orchestrator: her 2026-10-13 cast rule says Opus orchestrates to keep Fable
free for reviews; she redirects at kickoff. No `Sync/`, custody, Keychain, schema or editor-seam line is expected
(VX-347 is SwiftUI chrome and `EditorCommands`, not the TK2 seam); a trace reaching one says so to her first.

**Runs WITH one sitting:** VX-351's ticket carries her promise of "a brief design sitting when this ticket starts" —
the questions are under VX-351 below, so the kickoff sitting answers them and the rest of the run needs nothing from
her. Every other member is already ruled in her words on its ticket.

**The release:** at her explicit word only, never at a closeout (memory: Variorum release publishing); she usually
releases once the last of a set of runs is done. The next number is 0.9.8, then 0.9.9, then 0.10.0; no 1.0 before her
public launch. When she calls one: the notes are DRAFTED FOR HER provisionally every time while the app is pre-release
(her word 2026-10-18), one line per bullet, presented before the run; the release ends with the /Applications refresh under the full rule card, installing the
SAME version and build as the site; her Air then takes it through Sparkle.

## KICKOFF PROMPT (paste into a fresh session on the Pro, in `~/dev/variorum`)

> /architect-phase vx-348 — Run: Pre-launch bug sweep, her running list plus the today's-road pair and two riders;
> this file is your plan. Cast: Opus orchestrates (her 2026-10-13 rule; she may redirect), `opus-implementer` at
> xhigh, `fable-reviewer` at xhigh over the whole sweep's diff — fresh per unit/round. Mint the branch
> `vx-348-prelaunch-sweep` and the worktree `~/dev/variorum-vx-348` from `origin/main`, push the branch, add your
> in-flight row atomically, and run everything from the worktree. Nothing in `Sources/VariorumCore/Sync/`, custody,
> the Keychain or `Sources/VariorumCore/Protection/` (VX-378 holds that slot and that folder). The stage: claim
> `Tools/stage` for every Mac batch and walk; VX-381 and VX-382 share it, and a coordinator session
> (`oct18coordinator`, per VX-381's record) runs the stage this window — route every stage ask through it
> (REQUEST → READY → GO → RELEASE). Open the kickoff sitting with VX-351's questions (one question-tool batch), record her
> rulings in this file verbatim-faithful, then run without her. Where a ticket says "decide", decide PROVISIONALLY,
> record it here, and bundle it for QUESTIONS at the merge. Read `notes/MCPSpec.md` in full before VX-357 (the wire
> answer changes). Close with CLAUDE.md's full ritual; a release is her explicit word, not the closeout's.

## Members and the rulings they carry (each ticket's body is the trace; her words are already on them)

**Her running list**

- **VX-347** (High, Editor) — ⌘S always commits. Her report: *"command S should always commit your take even without an
  extra keystroke to enter (but if you click escape, then that can deliberately not save. the keyboard shortcut is
  lying right now since it's really command S enter)."* Her ruling supersedes QUESTIONS #121(b): the optional name
  field stays, and every way of leaving it except ⎋ FILES the commit (unnamed if nothing was typed) — ⏎, clicking
  away, typing on, closing the window. ⎋ alone is "don't save". Pointers: `EditorCommands.swift` (`.commitTake`); the
  13u3 UNIT D record in `notes/plans/phase-13u3-faces.md`; its pin `cancellingTheFieldFilesNothingAtAll` encodes the
  old rule and FLIPS (that is the red-on-old). The field is on every surface that hosts it — Write, Takes/Lenses, the
  book's editing modes, Canvas (Debug), Compare, Write's take panel: a sweep table, every host FIXED or SAFE. Walk
  both voices. The commit vocabulary is "commit" (R-13s-31/32).
- **VX-351** (High, Library & sidebar) — the exact edit time past today. Her ask: *"you should be able to see the
  actual time (with hours) that you last edited something at even if it's in the past."* **HER SITTING AT KICKOFF**
  (the ticket's promise). What exists: `TimeStampFace` drops the time past today by design; hover already shows the
  whole fact with the time on three surfaces (Library List rows, Library cards, the note masthead —
  `TimeStampFace.tooltip`), and a click flips edited/created (`FlippingStamp`). Gaps with no time and no hover: the
  Library info panel's facts line (`LibraryInfoPanel.factsLine`, a SECOND wording rule via `JournalDay.dayString` —
  the drift class) and the note box's stamps line (`NoteBox.stampsLine`, date-only by design). Other stamp speakers:
  the Timeline, the search answer sheet, the book's Arrivals and Archived lines, the MCP grant picker. **Her ideas
  (recorded, not decided):** (1) hover shows the full date and time; (2) a setting for the stamp's form — simplified
  as today · long "October 13th, 2026 at 4:02pm" · short "10/13/26 at 4:02pm" — and what a click shows.
  **The sitting's questions:** hover, click, a setting, or a mix? If a setting, which forms, every stamp or only the
  clicked one, and is it synced (a `setting` row is PLAIN enum semantics — a form name qualifies) or local? Which
  surfaces follow — at least the two gaps? Does the phone follow (a VM ticket)? The orchestrator's recommendation to
  bring: close the two gaps onto `TimeStampFace` (one wording rule, hover everywhere a stamp speaks) and build the
  setting only if she wants it now.
- **VX-350** (High, Library & sidebar) — the Library at narrow widths. Her words: *"the library's side pane is not
  adjusting, as you make the window smaller it just gets steadily cut off"*; the empty pill is the search field
  squeezed to nothing; *"it should at least turn into a search icon like magnifying glass and clicking on it should
  still do something, even if just opening it in the pane below."* At every narrow width: the info panel stays fully
  on screen (today its Close button disappears); the search field becomes a 🔍 button that still searches (at minimum
  opening the field below the controls row), never an empty pill; the rest of the row adapts (wrap or collapse a
  control). **Base:** VX-175 as shipped (VX-283) — AppSpec §12 THE LIBRARY'S CONTROLS ROW: ONE Layout, **never
  `ViewThatFits`** (the ticket's `LibraryBulkRow` precedent is superseded for this row by her ruling (C) and
  P-U3-5), and the row wraps by STABLE widths only, so typing, a sort pick or a search never changes the line count.
  The 🔍 collapse is a width-class decision inside that Layout, read from stable widths — keep the invariant and pin
  it (the VX-283 pins `R-P`/`R-S` are the harness). Walk both voices at 1240, ~940 and the window floor.
- **VX-357** (Medium, MCP) — U+0000 stored truncated. **Her ruling 2026-10-15, the shape she approved:** strip the
  null in ONE place, the operations layer (a pure Domain rule; every text-writing op family — takes, titles, labels,
  names, comments, the import, the wire — with a state-transition pin each); on the MCP door ALWAYS say it (the
  answer names how many null characters were removed; VX-254's `sha256` is the digest of the STORED text, so the
  fingerprint stays true); on her own doors, quiet. Not chosen: refusing; storing faithfully (a GRDB bind change).
  The known-issue pin `MCPWriteDigestServerTests.aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims` flips
  to a passing pin — that is the red-on-old. MCPSpec read in full first; its clause and the AI's docs say the strip.
  Prove the wire half in one real-client round (the dev store) if the batch window allows; the pins are the floor.
- **VX-349** (Low, Library & sidebar) — the doubled, extra-thick line under the List's "Notes" header at rest (one
  line while scrolling). NOT traced: trace first (the header's own hairline plus a scroll-edge or pinned-header
  separator drawn at rest is the suspect; the VX-20 dark heading work in VX-283 is the nearest code). A pin that
  counts the hairlines in the header's view tree is the red-on-old; if no pin can bite, say so in the record and
  prove it by the walk in both voices (P-6/P-7).

**The today's-road pair** (her ruling 2026-10-14, VX-266 design §9 call 4: *"yeah we can do the small bug fix."*;
folded into this sweep 2026-10-18 at her word)

- **VX-338** (High) — two Macs sharing a backup folder prune each other's backups. Today's `StoreBackup` /
  `BackupRetention` only. Shape: retention acts only on THIS Mac's own snapshots and never deletes another Mac's; the
  smallest form today's code allows (a per-Mac subfolder or a filename tag — design §5's cut line names both);
  existing shared folders are never cleaned up by deletion. Pin red-on-old: two Macs' snapshots in one folder, one
  prunes, the other's survive. Lane: no `Sync/`, custody, Keychain or `Protection/` lines; VX-302 stays open (the
  rebuild settles it its own way). **Fable reviews this member in particular (her word 2026-10-18).**
- **VX-339** (Medium) — Resume Sync clears the hold banner even when the marker removal failed. Today's
  `RestoreHoldModel.resume()` only. Shape: clear the banner only once the marker is gone; on failure say so and keep
  the hold visible. Pin red-on-old with a fake hold store whose clear fails. Same lane; VX-317 stays open.

**The riders** (born from VX-383's walk 2026-10-17; Pre-launch at her word 2026-10-18 — both Low, both Library code
this run already opens)

- **VX-384** — the mounted Library's List does not show a note minted from its own row menu until the surface is
  re-entered. Traced: the List is the one-shot `search()` answer (`LibraryCatalogView.swift` ~:280, re-run on wing,
  mode, filter and `.variorumNotesDeleted`), while `observeLibrary` feeds `posts` only; a mint from the row's menu
  re-runs neither. The faces-refresh class: VX-231 (Done, VX-246) owns the signal — use ITS road, never a second one
  (the runway's conflict map). Pin red-on-old: a row-menu mint lists the copy without re-entry.
- **VX-385** — the Pool has no home for a quiet receipt, so a receipt-only act from its rows speaks nowhere under
  `receipt_style` quiet. Fix shape: the shared `QuietReceiptLine` at the Pool's foot (VX-121's band rule applies if
  a quick-entry band is ever added there). Pin: the Pool hosts the line and a row act's receipt renders.

## Suggested units (the orchestrator re-sizes at kickoff and records it here)

1. **U1 — the core and the headless fixes:** VX-357 (the Domain strip, the op families, the wire answer, MCPSpec's
   clause) · VX-338 · VX-339. Headless `swift test` throughout; no stage until the Mac batch; the wire half's
   real-client round rides U3's window if the batch allows.
2. **U2 — ⌘S:** VX-347 across every host (the sweep table), walk both voices.
3. **U3 — the Library's row and header:** VX-350 · VX-349 · **VX-176 (joined at her overnight word — the same
   controls row; dark Terminal is one of the walked voices)**. Walk both voices at three widths.
4. **U4 — the Library's stamps and the riders:** VX-351 (built to her kickoff rulings) · VX-384 · VX-385 ·
   **VX-355 (joined at her overnight word — expected the same fix as VX-385; prove its cases, close it with the
   record saying so)**. Walk.

Then the ladder (Fable, fresh per round, over the whole diff), the closeout, the merge.

## Overlaps to respect (the runway's §2 conflict map, as of 2026-10-18)

- **VX-381 (part A)** owns the gathering doors and copy, `Operations+SmartCollect`, `Operations+Tag` (undo), the
  shared-note notice, `CalmButtonStyle` and the Settings scene's `.opening` arm. VX-357's strip touches the
  TEXT-writing operations; A's ops write no prose — folder-level neighbours only, rebase care.
- **VX-382 (part B)** owns the book views, `SidebarNoteBox`, the shell's landing road, the Book Panel and the order
  popover. VX-347's name field is hosted on the book's editing modes: if the field lives inline in `BookView` /
  `BookIndexView` rather than in a shared component, whoever lands second rebases — say so to B's session at kickoff.
- **The Castle corrector (VX-305/VX-378)** owns `Sources/VariorumCore/Protection/` and the one `Sync/`-or-custody
  slot. VX-338/VX-339 are fenced to today's backup and hold-banner code and never enter that folder.
- **VX-234** (her Settings wording pass) may touch pane copy; VX-351's setting, if she wants one, lands in a pane —
  rebase carefully.
- **Closeouts serialize** (CLAUDE.md): the three runs merge first-ready-first, each rebasing.

## Environment traps (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration; suites running beside a live session flash the test host's windows on
screen; backups WAL-safe with UTC names, ALWAYS before touching the real store (this run never touches it before the
closing refresh's A1 copy); screenshots in gitignored dirs only; never `git checkout` over uncommitted work; commit
per piece and push after every commit (`notes/SessionResiliencyProtocol.md`); synchronous foreground waits only —
poll a log with `grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop, never `tail -f | grep -m1`; never
force-push, never rewrite history; commits name their member and `Part of VX-348`, with NO attribution trailer of any
kind; the PR body names VX-348 only (a "Part of VX-284"-style mention closes the named ticket at merge). The dev
store's Castle credentials, if a lock screen appears, are `~/.variorum/dev-castle.env` (never invent, never commit).
A pin that goes red only after a rebuild from the fixed tree is hollow: build the red product from the reverted
file(s), then `test-without-building` (VX-383's slip). Before `release.sh`: move any untracked `default.profraw` out
of the repo root; main frozen from the version-bump commit until the stamp; one line per release-notes bullet.

## LIVE STATUS

- **Kickoff (2026-10-18):** branch `vx-348-prelaunch-sweep` + worktree `~/dev/variorum-vx-348` minted from
  `origin/main`, pushed; in-flight row added atomically; VX-348 + all nine members In Progress on the board. The
  kickoff sitting ran (rulings R-VX348-1…4 above); VX-389 and VM-22 minted. Units adopted AS the plan suggests
  (U1–U4, re-sizing recorded: none needed). Stage via `oct18coordinator` (REQUEST → READY → GO → RELEASE); the
  sync/custody slot is VX-378's — anything that looks like it needs it is DEFERRED (her kickoff word).
- **U1 (VX-357 · VX-338 · VX-339 — the core and the headless fixes):** NOT-STARTED.
- **U2 (VX-347 — ⌘S):** NOT-STARTED.
- **U3 (VX-350 · VX-349 · VX-176 — the Library's row and header):** NOT-STARTED.
- **U4 (VX-351 as ruled · VX-384 · VX-385 · VX-355 — stamps and riders):** NOT-STARTED.
- Then the ladder (fresh Fable per round, whole diff), closeout, merge. **Her overnight mandate (2026-10-18):**
  rule PROVISIONALLY and continue; merge to main at this run's own finish (finish-order serialization with
  VX-381/VX-382); leave the handoff AND, separately, the completed checklist block in her format. **Release (her
  word, confirmed in-session):** the LAST of the three runs to merge mints ONE 0.9.8 covering all three; VX-378 may
  merge in and ride but never mints and is not counted. BEFORE this run's merge ask: land its section in
  `ReleaseNotes-0.9.8.md` on this branch (one-line bullets). First/second merger: no bump, no refresh. Last (the
  coordinator says so explicitly): release.sh + the folded /Applications refresh under a GO'd stage window, full
  rule card.
- **The trailer slip, closed:** the kickoff's in-flight-row commit briefly carried a `Co-Authored-By` trailer; at
  her word she force-pushed the amended commit herself — main `d35b07515` → `fdce74de3`, identical tree. No other
  commit carries one.
