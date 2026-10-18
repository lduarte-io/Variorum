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

5. **U5 — the urgent MCP trio (joined 2026-10-18 while U1 ran, her word):** VX-392 · VX-393 · VX-394 — the section
   below carries her words, the rulings and the client-session report VERBATIM. **Runs NEXT after U1** (urgent
   outranks U2–U4). MCPSpec read IN FULL by its implementer first. Mostly headless (`Tests/VariorumMCPTests` + the
   grants store) plus the pane's faces; VX-392's done-when is proven by a real-client live round on the dev store
   (an empty wing granted → found in one call → a book created unaided) riding a coordinator window.

Then the ladder (Fable, fresh per round, over the whole diff), the closeout, the merge.

## U5 — THE URGENT MCP TRIO (2026-10-18, joined at her word while U1 ran)

Her words, verbatim: *"ok there's an urgent ticket that is an MCP issue that I need you to add to the plan to fix
within this sweep. I don't think the other sessions have anything running in the MCP area particularly so I don't
anticipate conflicts. […] the issue is that even when there's a whole wing grant, claude can't see it or write in
it."* And, after the tickets were minted: *"make sure you read the MCP document that claude.md points out before
working on these if you haven't already"* — the orchestrator read `notes/MCPSpec.md` in full at this run's kickoff
(before U1, for VX-357); U5's implementer is bound to the same full read by its brief. Her screenshot (Settings ▸
MCP ▸ Shared with AI) shows the duplicate rows VX-393 names: PlanetLillian (wing) twice for claude-code —
`read · always` AND `read, suggest, write new and edit · always` — and "o ladrão de raios" (book) twice.

**The sitting's two rulings (asked while she was still up — the report itself says "Ask me before changing any
user-facing grant semantics"):**

- **R-VX348-5 (VX-392, discovery):** she picked **"list_wings tool"** (the recommended option, selected with its
  preview): a new read-rung tool returning each wing the client holds a standing wing grant on — name, `wing_id`,
  its own rungs and duration, note/book counts; ungranted wings simply absent (the no-oracle rule); the
  instructions and the `create_book`/`create_note` docs point at it; `list_books` also fixed to list a
  granted-but-empty book.
- **R-VX348-6 (VX-393, duplicates):** she picked **"Upgrade in place"** (recommended): ONE row per client ×
  target — a new grant on an existing pair REPLACES the row (the Change… sheet's semantics applied to every grant
  road); existing duplicates merge to the strongest rung at migration; Revoke then means what it says, nothing
  stronger left behind silently.

**The client-session report she pasted (verbatim — the U5 implementer's trace source):**

> I'm launching Variorum this week, and a Claude Code session using the Variorum MCP server just hit a serious
> bug, plus a few smaller ones. Please investigate and fix them in priority order. For each one: reproduce it,
> find the cause in the code, fix it, add a test, and tell me what changed. Ask me before changing any
> user-facing grant semantics.
>
> **1. CRITICAL — a client can't discover a wing shared with it while the wing is empty**
> Repro: 1. Create a new wing ("PlanetLillian") with no notes and no books. 2. In Settings ▸ MCP ▸ Shared with
> AI, grant it to a client (`claude-code`) at `read, suggest, write new and edit · always`. 3. From that client,
> call `list_books` and `list_notes` (with no arguments).
> Observed: `list_books` returns only Home books. `list_notes` returns only notes with `wing_id: ""`. The shared
> wing never appears anywhere. `create_book` and `create_note` need a `wing_id`, and `search` and
> `list_my_activity` can't surface it either, so **the client has no way to make its first write into a wing it
> was explicitly granted.** The grant UI shows the share, but the MCP's discoverable surface doesn't. Workaround:
> the author manually adds a note so the wing's ID leaks through `list_notes`. Nobody will know to do that.
> Expected: every wing granted to a client can be discovered, empty or not.
> Suggested fix: add a `list_wings` tool that returns each shared wing's `wing_id`, name, grant rungs, duration
> (once / until disconnect / always), and note and book counts. Or add a `wings` array to `list_books`. Either
> way, update the server instructions and the `create_book` / `create_note` docs to say where `wing_id` comes
> from. Also check the same gap for an empty book granted on its own, and for a wing with gatherings but no
> books.
> Done when: a fresh client granted an empty wing can find it with one call and create a book in it with no help
> from the author.
>
> **2. Duplicate grants for the same client and target**
> Shared with AI lists PlanetLillian twice for `claude-code` (`read · always` and `read, suggest, write new and
> edit · always`), and "o ladrão de raios" twice as well. Find out how that happens: re-approval, a later
> upgrade, or separate sessions. Then either merge grants for the same client and target into the strongest rung
> (showing upgrades as an edit to the existing row), or label clearly why there are two rows. Make sure revoking
> one row doesn't silently leave a stronger one in place without the author knowing.
>
> **3. Mid-session disconnect while the server says "running"**
> Partway through a long Claude Code session (around 3–4 AM, Mac likely idle), all Variorum tools vanished with
> "MCP server disconnected". The app still showed "running · socket in the app container". Running `/mcp` →
> reconnect fixed it, and the `always` grants survived. Investigate: App Nap or idle throttling of the server
> (consider `ProcessInfo.beginActivity` while clients are connected); idle timeouts on the socket; the socket
> path changing across app restarts or sleep. Add a line to Settings ▸ MCP ▸ Diagnostics/Activity when a client
> connection drops, with the reason if known.
>
> **Keep as is (it works well):** At session start, before Variorum was open, the client got a clear error
> ("open Variorum and enable the MCP server"). Once the app opened, it connected mid-session without a restart.
> Don't regress that.

**U5 build notes (the orchestrator's, binding the brief):** VX-392 ALSO verifies the non-empty wing-grant road end
to end (her framing is "can't see it or write in it", wider than the empty repro) and the gatherings-only wing.
`list_wings` answers the CLIENT'S OWN grants — no oracle arises — and reads ∝ the granted wings, never the corpus
(P1). VX-393's dedupe may need a LOCAL-ONLY grants-family migration (the v1_26–v1_29 precedent: local, zero
lockstep, marker untouched — the in-flight row's "no schema" fence means the SYNCED schema); the trace must say
which road minted the duplicates (the grant sheet's roads inserting where Change… replaces is the suspect). VX-394
is investigation-first (no fix without a traced mechanism — if the cause cannot be reproduced, land the Activity
drop line + the keep-alive only if its mechanism is established, else record findings and keep the ticket open,
PROVISIONAL). The VX-180/VX-181 behaviors (closed-app sentence, mid-session connect) must not regress — their pins
re-run in U5's batch.

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
- **U1 (VX-357 · VX-338 · VX-339 — the core and the headless fixes):** BUILT — all three FIXED with pins (`9c3ec7ac2` ·
  `85640635b` · `4aa81c0a6` VX-357; `481a69c6c` VX-338; `cf194996b` VX-339); VX-357's pins verified RED on the pre-fix
  tree and the headless suites green; **the Mac batch RAN 2026-10-18 ~04:2x under claim `vx-348-u1-batch`** — RED
  leg 7/2: VX-338 4 of 5 red + the pure guard green, VX-339 2 of 2 red, exactly as predicted; FIXED leg 78 tests /
  13 suites ALL GREEN. U1's pins are verified red-on-old whole. **Still PENDING:** VX-357's real-client wire round
  (a later window) and the VX-339 banner walk. The U1 UNIT RECORD (below) carries the rest.
- **U5 (VX-392 · VX-393 · VX-394 — the urgent MCP trio, joined 2026-10-18 at her word):** BUILT — VX-392 FIXED
  (`7998e88a5` — `list_wings`), VX-393 FIXED (`00c754151` the local-only `v1_30` · `98c88a686` the one-row rule),
  VX-394's drop line SHIPPED (`6306a21ff` · `0784d8b9a`; the mechanism established — Castle's re-lock stops the server —
  and HER lock question recorded, not built); every headless pin verified red-on-old; the headless suites green but
  VX-353's flake; the fold of main is in (`460d39785`). **PENDING:** the Mac batch (products prebuilt from the folded
  tree — the U5 record's last sections), VX-392's real-client live round, the QUESTIONS bundle (P-VX392-1…5,
  P-VX393-1…3, P-VX394-1…6). The U5 UNIT RECORD (at the end of this file) carries the rest. **The batch ran (see THE
  U5 BATCH + LIVE ROUND): one red, live-confirmed — the stop roads wrote no end line; the FIX LEG landed `0ebf5c926`
  (a connection now writes its own end through its own store; the cause was the door dropping its host before the
  host's sessions ended), headless proof green; the Mac pin's re-run on `DerivedData/u5-fix` rides the orchestrator's
  next stage window (the U5 record's "VX-394 fix leg" section has the command).**
- **U2 (VX-347 — ⌘S):** BUILT — FIXED at the one shared seam (`acbe5e5cb` the fix · `36c715ac2` the pins: every leave of the
  ⌘S name field but ⎋ files, the filers commit the ASKED take); compiled; **PENDING:** the Mac batch (red leg first —
  products in the U2 record), the walk (both voices, every host — the list in the record), the QUESTIONS bundle
  (P-VX347-1…5). The U2 UNIT RECORD (at the end of this file) carries the rest.
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
- **VX-381 MERGED FIRST (main `d4b104e8a`, PR #170, 2026-10-18 ~04:4x — the coordinator's notice):** so the LAST of
  VX-382/VX-348 mints 0.9.8. OWED at the next clean seam (U5's implementer holds the worktree now — the merge waits
  for its finish): merge `origin/main` into this branch; its delta reaches `Shared/OpsRefusalTable.swift` and the
  gathering doors — diff both sides for overlap with this run's surfaces, SAY SO in the merge ask, and re-run the
  affected suites headless. Every later unit builds on the merged tree. **Castle MERGED (main `aeabdd75b`, PR #171, closes
  VX-378/305/345; the coordinator's verified footprint: `Protection/` + its tests + three core test files + CLAUDE.md
  — `notes/CastleRules.md` joins the read-explicitly list — + notes; zero `Sync/`, `App/` or `Server/` lines, nothing
  on this run's surfaces, no re-test owed):** ONE fold covers both main moves — **and HER WORD (~05:0x, via the
  coordinator) SUPERSEDES the next-seam plan: every session folds main at the NEXT AVAILABLE CHANCE, before any new
  walk or stage window. main is `d8bb24488` (VX-381 + Castle + two notes-only commits). The U5 implementer is
  instructed: fold at its next commit boundary (fetch + merge origin/main, keep-both-sides on any conflict, a merge
  commit, `swift build` sanity, the overlap answer in its record); no U5 batch or live round takes the stage until
  the fold is in; U5's READY states the fold and the OpsRefusalTable overlap answer. THE MECHANISM (the coordinator,
  from the closing VX-378 session): VX-306 — Castle phase 2, kicking off — converts the fenced dev store at its
  first Debug open (new protection record + key file format 3), after which a Debug build or TEST HOST from a tree
  without `aeabdd75b` cannot open the dev store at all — so the fold gates EVERY xcodebuild test batch, walk and
  live round from here on, and every prebuilt test product must be built from the folded tree (the implementer told
  so). The coordinator announces when the conversion has happened.** The release rule unchanged:
  Castle never mints, isn't counted; the last of VX-382/VX-348 mints 0.9.8 and carries Castle. The Sync/-custody
  slot is now free; nothing in this run's lane needs it — the kickoff fence stands regardless.
- **The trailer slip, closed:** the kickoff's in-flight-row commit briefly carried a `Co-Authored-By` trailer; at
  her word she force-pushed the amended commit herself — main `d35b07515` → `fdce74de3`, identical tree. No other
  commit carries one.

## U1 UNIT RECORD (VX-357 · VX-338 · VX-339 — the core and the headless fixes)

*Implementer: `opus-implementer` at xhigh, fresh session, 2026-10-18. Read in its own context before any code: this plan
in full, `notes/SessionResiliencyProtocol.md`, `notes/MCPSpec.md` in full, CLAUDE.md + its canon, the three tickets'
bodies and their parents' (VX-302, VX-317), the VX-266 plan's cut line (§5 "a filename tag would do") and design §5.*

**NOT DONE BY THIS UNIT (first line, by the brief's rule):** the Mac batch (`xcodebuild test`) and every walk — the stage
is the orchestrator's this window; the Mac-side pins are written, compiled `build-for-testing`, and their red-on-old
legs PREBUILT (locations below) so the batch window only runs `test-without-building`. No real-client MCP round (U3's
window, if the batch allows).

### LIVE STATUS (per member)

- **VX-357 (U+0000 stored truncated):** DONE (`9c3ec7ac2` the fix · `85640635b` the pins · the docs commit below) —
  FIXED with its pins, every new pin verified RED on the pre-fix tree; the headless suites green at the end (one
  load-dependent timing flake, green alone — below). The real-client wire round is PENDING (U3's window, if the batch
  allows). Its section below.
- **VX-338 (two Macs prune each other's backups):** DONE (`481a69c6c`) — FIXED; its pins compile (`build-for-testing`
  green); **both legs RAN at the orchestrator's batch (04:2x): 4 of 5 RED on the red product (the pure guard green),
  all green on the fixed** — red-on-old VERIFIED. Its section below.
- **VX-339 (Resume Sync clears the banner over a failed marker removal):** DONE (`cf194996b`) — FIXED; **both legs
  RAN at the orchestrator's batch (04:2x): 2 of 2 RED on the red product, green on the fixed** — red-on-old
  VERIFIED. Its section below. No walk yet (PENDING: the banner's failure line in both voices needs a held marker
  on the dev store — a later window's call).
- **No behavioural revert is in flight.** (The Mac red product's reverts ran on committed `cf194996b` and were
  restored by `git checkout --`; `git diff` clean after. The earlier targeted `editCommentForClient` revert likewise.)

### VX-357 — U+0000 is stripped in the operations layer; the wire says how many

**The trace (inputs → wrong state).** GRDB binds every TEXT value with length -1 (`sqlite3_bind_text(…, -1, …)` —
`GRDB/Core/Support/StandardLibrary/StandardLibrary.swift:625`), so SQLite reads a bound value only up to its first NUL.
A take written as `"before\0after"` (12 bytes) is stored as `"before"` (6): everything after the null character is
silently LOST, on every road text reaches the store (a paste into a block → `autosave`; a paste into the open tail →
`importBlocks`; File ▸ Import → `importDocument`/`importBook`; a comment, a title, a label, a name, a commit message;
the MCP door). The wire compounds it: VX-254's `sha256` is computed from the act's own row in memory (D-254-1 — no
second read), so for such a take it digested the 12 bytes SENT while the store held 6 — the one case the fingerprint
overclaimed (pinned as a known issue by VX-336 U7, `aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims`).

**The fix (her approved shape, no product invention).**
- **ONE pure Domain rule** — `Sources/VariorumCore/Domain/StoredText.swift`: `stripped` removes every U+0000 and
  nothing else (byte-level: 0x00 occurs in UTF-8 only as U+0000 itself, so the result is exact and valid; a
  no-allocation fast path when there is none), `nullCount`, `containsNull`. It composes into the three Domain rules
  faces also consult, so face and store agree: `SavepointName.normalized` (every savepoint name), `TagPath.segments`
  (every typed tag path — applied, removed, a book rule's or outflow's), `BookNaming.key` (the book- and wing-name
  guards collide a typed name as it will be stored).
- **Applied in the operations layer, never door by door:** every op that writes caller-supplied text strips it FIRST
  — before its validation, no-op guard, counts and undo capture — and the shared mints strip again at the row
  (`mintBlock`, `mintFanBlock`, `insertPost`, `insertTag`), so no mint road, a future one included, can store a null.
  The sweep, op by op (each FIXED, by family):
  | family | ops (strip site) |
  |---|---|
  | takes | `autosave` · `newBlock` · `importPost` / `importBlocks` (before segmenting) · `editTakesAtomically` (each edit's new text) · `mintBlock` / `mintFanBlock` (the row — documents, structured notes, `insert_blocks`, every structural mint) · the wire's `insertSuggestedTake` (`add_take`/`add_takes`) · `editTakeUnderInsurance` (`edit_take`) |
  | titles · notes · references | `insertPost` (the row — `createPost`, `importPost`, documents, `newPostInReading`, the wire's notes) · `createPool` · `renameContainer` · `renameNoteForClient` · `createNote`/`createStructuredNote` (before trimming) · `updateFloatingNotes` · `addReference` (name, url) |
  | labels | `setTakeLabelRows` (her `setTakeLabel` + `set_take_label`) · `insertSuggestedTake` · `mintBlock`/`mintFanBlock` (import labels) · `MCPWriteTools.aiLabel` (the client's own label) |
  | names | `setBlockName` (hers + the wire's) · structured-note / `insert_blocks` block names · lens: `createLens`, `renameLens`, `duplicateLens`, `branchAllFans`, `saveLens` · reading: `createReading`, `renameReading`, `duplicateReading`, `saveFilterAsGathering`, `createBook`, `renameBookForClient`, `importBook` (book + chapters) · chapter: `insertSection` (hers + `create_section`), `renameSectionRow` (hers + `rename_chapter`) · `createShelf`, `renameShelf`, `setShelfGlyph` · `createWing`, `renameWing` · tag: `insertTag` (every mint), `renameTag`, `TagPath` (every path) · commit messages: `SavepointName` (commit, rename, `save_commit`, `rename_commit`) + `mcpCommitMessage` |
  | comments | `insertBlockComment` (hers, `add_comment`, `add_comments`) · `rewriteComment` (hers, `edit_comment`) · `editCommentForClient` (its undo capture) |
  | the import | `importDocument`/`importBook` via the rows above; a take of nothing but nulls is blank as stored, so the file doors drop it like any blank take; the note's baseline counts the stored text |
  | the wire | rides every op above; plus the count (below) |
- **The wire, always said, in ONE place:** `MCPWriteTools.land` — every landed write's answer passes through it — adds
  `null_characters_removed` (an integer: how many the act removed from the text it wrote) when it is > 0, read from
  `Job.nullCharactersWritten` (`Sources/VariorumMCP/MCPNullCharacters.swift`), an EXHAUSTIVE switch over every
  tool's parsed call and its nested jobs (`flushesHerEditorFirst`'s shape — a new tool cannot compile without
  saying). Counted: the texts a call writes (take text and label, comment, title, every name, commit message, a tag
  path applied or named in a rule/outflow, every text of an import). Not counted: ids, preconditions
  (`expected_text`), locators (`second_half_starts_with`, a lens rule's label match, `remove_tag`'s path), validated
  day keys. VX-254's `sha256` now digests the STORED text by construction (the row the op returns is the stripped
  one), so the fingerprint is true again.
- **The AI's docs:** `MCPToolCatalog.nullSentence` — one shared sentence naming the answer key — rides the six tools
  that answer the sha256 of text the client SENT (`add_take`, `add_takes`, `create_note`, `import_document`,
  `insert_blocks`, `edit_take`); `MCPSession.instructions` is untouched (no sentence in it became untrue; still inside
  its 3,000 bound). **MCPSpec:** the write-digest clause's VX-357 sentence is now the contract line plus the pointer to
  this record, and the record joins the binding-records list.

**Deliberate exclusions (each argued, none silent).**
- `resolveSyncConflict` and remote apply (Sync/'s): the text comes from the engine, and every device's store binds
  the same way, so no stored row anywhere can hold a null to send — and the lane (VX-378's slot) is fenced. No
  `Sources/VariorumCore/Sync/` line.
- MCP client and setup NAMES (`recordMCPContact`, `admitMCPConnection`): an identity, not prose — and every LOOKUP
  binds the same name too, so stripping only the writes would split the stored name from every query. **Recorded
  for the orchestrator (a candidate ticket, not this unit's):** a `clientInfo.name` holding a NUL is, to every SQL read
  and write of that session, the prefix before it (the same truncation, on an identifier); the A-4 setup-key binding
  is what stands between such a name and the prefix's grants. Ids bound with a NUL resolve to their prefix the same way.
- JSON-encoded columns (`block.presentation`, `reading.query_spec`/`auto_tag_ids`, a reference's `view_state`, canvas
  layouts, lens picks): `JSONEncoder` escapes U+0000 as `\u0000`, so no raw null is ever bound there. Settings: typed
  enums and validated values only (`ThemeTint` refuses anything but a colour).
- Preconditions and locators (`expected_text` on `edit_take`/`edit_comment`/`moveSpanToNewTake`/the compound,
  `second_half_starts_with`): compared with what is stored, which never holds a null, so one that holds a null never
  matches — the honest refusal (`bufferChangedSinceGesture` / the stale-read sentence), never a wrong write.

**FINDING FOR THE ORCHESTRATOR — the editor seam (out of U1's lane; nothing done).** A null pasted into the LIVE
editor stays in its `NSTextStorage` until the note re-renders, while `autosave` stores the take without it. Until
then a structural act from that block either refuses (an `expectedText` precondition no longer matches) or — for
an offset-addressed act, `divide(_:cut:)` — lands its cut offset by the number of nulls before it. (Before the fix
the same paste LOST everything after the null at the next autosave — strictly worse.) The tidy fix is the editor's
own insert door (`EditorTextView.paste`/`insertText` passing pasted text through `StoredText.stripped`, and the
phone's twin) — an editor-seam line (TEXTKIT2_NOTES; Fable's review), so it is NOT built here: a VX ticket or the
editor-seam batch's call.

**Pins (each a state-transition pin; RED ON OLD verified on the pre-fix tree — a scratch worktree at `231b44d24`
with the new test files copied in: every new pin below failed there, for the truncation; the run log's lines read
`row.text == expected`, `storedBytes == 11`, `null_characters_removed == 1` failing).**
- `Tests/VariorumCoreTests/StoredTextNullStripTests.swift` — one per family, row text AND byte length:
  `takesKeepEveryWordAroundANullCharacter` (newBlock · autosave · importBlocks),
  `theCrossBlockCompoundStoresItsTextWithoutTheNull`, `titlesNotesAndReferencesStoreWithoutTheNull`,
  `labelsNamesAndCommitMessagesStoreWithoutTheNull`, `libraryNamesStoreWithoutTheNull`, `commentsStoreWithoutTheNull`,
  `theDocumentAndBookImportsStoreEveryTextWithoutTheNull`, `theBulkImportDoorStoresItsTitleAndTextWithoutTheNull`,
  `theWiresActsStoreWithoutTheNullAndTheirUndoRoundTrips` (add_take, edit_take + its ⌥⌘Z/⇧⌥⌘Z, add_comment,
  edit_comment + its undo/redo, rename_note + its undo) — 9 of 9 RED on old. The undo-capture leg was also proven by
  a TARGETED behavioural revert on the fixed tree (`editCommentForClient`'s entry strip removed → the entry's undo
  retired quietly, `edit_comment's undo` failed; restored by `git checkout --` on committed `85640635b`).
- `Tests/VariorumMCPTests/MCPWriteDigestServerTests.swift` — the known-issue pin FLIPPED to
  `aTakeHoldingUPlus0000IsStoredWithoutItAndTheAnswerSaysHowMany` (11 bytes stored, `read_note` = "beforeafter",
  sha256 = the stored text's, `null_characters_removed` = 1) — RED on old (6 issues).
- `Tests/VariorumMCPTests/MCPNullCharacterServerTests.swift` — `aStructuredNoteIsStoredWithoutItsNullsAndTheAnswerCountsThem`
  (six nulls across title, text, name, take, label), `anEditIsStoredWithoutItsNullAndARespellingByNullsIsNoChange`,
  `aCommentWithANullStaysTheClientsOwn` (VX-260's authorship digest reads the stored words — the client still deletes
  its own comment at suggest), `aBatchAndATagCountEveryNullTheyRemoved` — 4 of 4 RED on old;
  `aWriteWithoutANullAnswersWithoutTheKey` and `theDigestToolsDescriptionsSayTheStrip` are guards (green on both
  sides by design: the byte-unchanged promise, and the docs).
- `Tests/VariorumCoreTests/StoredTextTests.swift` — the rule itself (new API; a unit test, not a red-on-old pin).

**Suites (headless, at the end of the piece):** `swift test` whole — VariorumCoreTests 2908 tests / 339 suites
passed; the third target 40 / 6 passed; VariorumMCPTests 368 / 69 with ONE failure,
`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.7 s against its 15 s
bound while the machine's load average stood at 16–19 — other sessions' builds), green alone (3 / 3 in 2.2 s); the
harness's own timing guard, untouched by this diff.

**PROVISIONAL, for the merge's QUESTIONS bundle (the run's rule: decided here, bundled at the merge):**
- **P-VX357-1** — the answer's key is `null_characters_removed`, an INTEGER (the count is the "worded" answer: a
  plain-English key, never a Swift case); alternatives: (b) add a sentence key beside it; (c) one sentence only.
- **P-VX357-2** — present only when > 0, so every other answer is byte-unchanged (MCPSpec's byte-unchanged promises);
  alternative: always present (0 included).
- **P-VX357-3** — the null sentence rides the six tools that answer a digest of SENT text; the other text-writing
  tools (comments, names, labels, titles, messages, tags) answer the same key without a description line;
  alternative: the sentence on every text-writing tool.
- **P-VX357-4** — a precondition or locator holding a null is NOT stripped (it refuses honestly); alternative: strip
  them too (an `expected_text` sent with a null would then match).
- **P-VX357-5** — an `edit_take` whose text differs from the stored text only by nulls answers `changed: false` with
  the count said.

### VX-338 — the far folder's sweep acts only on this Mac's own copies

**The trace (inputs → wrong state; VX-302's code map, re-read here).** The iCloud Drive offer opens its picker at
iCloud Drive's root (`ICloudDriveOffer.swift:101-106`) and every run copies into `<pick>/Variorum/Backups`
(`BackupDestination.backupsFolder`), so two Macs on one Apple account that both accept it — her Pro and her Air —
write into ONE folder. After each copy the far leg swept it: pre-fix `StoreBackup.pruneSecond` (`:433-444`) listed
EVERY app-named snapshot there (`existingBackups`, `:704-716` — whichever Mac or library wrote it) and deleted what
`BackupRetention`'s 14+4 rule did not keep. The rule keeps one file per day, the NEWEST (`BackupRetention.keep`,
`:87-118`), so on a day both Macs wrote, the earlier Mac's copy fell into the remainder and was deleted unless it
claimed a weekly slot — each Mac's run deleting the other's copies, every day.

**The form chosen — a device-local list of this Mac's own copies (PROVISIONAL P-VX338-1).** The brief names two forms
(VX-266 design §5's cut line: a per-Mac subfolder, or a filename tag) and asks for the smallest today's code allows.
Weighed against the code, both reach past the two files the brief fences:
- **A filename tag** changes the snapshot's NAME, and backup names have readers outside `StoreBackup`:
  `BackupRestoreCandidates.backupDate` (core — Restore from Backup lists only `-<fp8>` or bare tails) and
  `LibraryClassifier.backupNameFingerprint` (core — the open road's key-file pairing), plus the Data Safety copy that
  spells the name format to her (`DataSafetyCopy.swift:178-182`). Unmatched, every new snapshot would vanish from
  Restore from Backup — a regression this fix cannot ship.
- **A per-Mac subfolder** hides every new copy from every reader that lists the folder flat — the restore list's
  caller, the Data Safety face's freshness (`DataSafetyModel.swift:207`) and the Castle switch's pre-switch listing
  (`PostureSwitch.swift:1950-1957`, VX-378's lane): an Apple-openable copy in a subfolder would escape the Castle offer.
  The worst of the three.
- **The list** — `StoreBackup.ownFarSnapshots` (`UserDefaults` key `variorum.backup.ownFarSnapshots`, device-local
  like the folder's bookmark and the run log; the `pendingLockTimeChecks` precedent) — changes nothing any reader
  sees: names, folders, the restore list, the classifier, the Castle switch and the face are byte-identical. Only
  `StoreBackup.swift` and `BackupRetention.swift` changed. Its one trade-off against the tag, said: an OLDER build on
  the other Mac still sweeps everyone's copies until that Mac updates (a tag would hide new copies from old builds);
  her two Macs take the same Sparkle release, so the gap is the days between their updates.

**The fix.** `performSecondLeg` records the name of the copy it just wrote (`recordOwnFarSnapshot`, right after its own
`copyItem`); `pruneSecond(in:policy:defaults:)` sweeps with `BackupRetention.prune(_:policy:ownedBy:)` — the unchanged
14+4 rule over ONLY the candidates whose names are on the list — and rewrites the list (in a `defer`) to the own copies
still present. The in-container `Backups/` keeps its flat newest-14 (it is per-Mac by location: this Mac's container,
this Mac's disk), and so does the lock-time copy.

**THE DELETION-SAFETY ARGUMENT (for the Fable read her word names).**
1. Retention deletes in the far folder at exactly one line: `pruneSecond` → `removeSnapshotPair(url)` for each
   `url ∈ doomed`. (The Castle switch's user-confirmed deletions are a separate door, untouched.)
2. `doomed = BackupRetention.prune(candidates, policy:, ownedBy: own)` = the old rule applied to
   `candidates.filter { own.contains(name) }`, so `doomed ⊆ { c | name(c) ∈ own }` — a pure property, pinned
   (`theOwnSweepNeverReturnsACopyThatIsNotOwn`).
3. A name enters `own` at ONE place: `performSecondLeg`, immediately after THIS Mac's `copyItem` of THIS act's own
   snapshot into the folder succeeds. Nothing else writes the list; the other Mac's list lives in the other Mac's
   defaults and is never read here.
4. So a file is deleted only if this Mac itself wrote a file of that exact name into the folder. Another Mac's file
   could share the name only if both Macs snapshotted under the same key fingerprint (or both unkeyed) in the SAME
   UTC second — and then the later copy has already REPLACED the earlier at its own copy (the pre-existing
   `removeItem`+`copyItem`, `performSecondLeg`), so the folder holds one file that is both Macs' — no other Mac's
   distinct file is reachable.
5. Copies written before the fix are on no Mac's list, so they are never deleted — an existing shared folder is never
   cleaned up by deletion (the ruled shape), pinned (`copiesWrittenBeforeTheFixAreNeverDeleted`).
6. Every failure mode fails toward KEEPING: a lost list (wiped defaults, a new Mac) is empty → nothing deleted; an
   unreadable folder throws before the list is touched; an iCloud placeholder not yet downloaded
   (`.name.sqlite.icloud`) is not an app name → never a candidate, and leaves the list at reconcile → never deleted
   later; a throw mid-sweep still rewrites the list to exactly the own copies left.

**Consequences, recorded (none silent):**
- (a) This Mac's OWN pre-fix far copies (≤ 18) are never pruned now either — a one-time leftover on every far folder,
  single-Mac ones included, until her hand or the rebuild's catalog (VX-302 / VX-309) settles it. **P-VX338-2:**
  alternative — adopt a pre-fix copy as own when it is byte-identical to a snapshot beside the library (provable) —
  NOT built: it deletes existing files, which the ruling's last sentence rules out.
- (b) **Finding for the orchestrator (not retention; unchanged):** the far leg's DUE-check still reads every app-named
  copy, so another Mac's copy from the last 24 h answers this Mac's hourly far leg "up to date" (no write). For one
  synced library that copy is as good; for two different libraries sharing one folder, this Mac's far copy waits.
  The rebuild's per-library catalog settles it (VX-302).
- (c) The Data Safety face still counts every copy in the folder (both Macs') — unchanged, and true of the folder.

**Pins** (`App/Variorum/VariorumTests/VX338SharedBackupFolderTests.swift`; two Macs = two containers, two defaults
domains with a bookmark of ONE picked folder, every run the real `performRun`, forced):
`anotherMacsCopiesAllSurviveThisMacsSweep` (the ticket's pin: the Air's twenty days, then the Pro's run — every Air
copy survives, the Pro prunes 0) · `eachMacPrunesItsOwnCopiesByItsOwnRuleAndNeverTheOthers` (forty alternate days:
each Mac's survivors are EXACTLY its own rule's keep over what it wrote — retention still works — and nothing else
is in the folder) · `copiesWrittenBeforeTheFixAreNeverDeleted` (twenty real pre-fix copies survive thirty runs) ·
`thisMacsListFollowsTheFolder` (the list = this Mac's copies there; a copy gone by hand leaves it) — each expected RED
on the red product (the first three by the old sweep, the fourth by absence: no list exists);
`theOwnSweepNeverReturnsACopyThatIsNotOwn` — the pure rule (a guard, green on both). **RAN at the batch: exactly as
expected (4 red + the guard green on u1-red; all green on u1-fixed).**

### VX-339 — Resume Sync clears the banner only once the marker is gone

**The trace.** `RestoreHoldModel.resume()` (pre-fix `:81-89`) called `LibraryRestoreHold.clear(besideStore:)` —
which ANSWERS whether the marker is gone (`@discardableResult … -> Bool`) — ignored the answer, set `hold = nil` and
ran `onResume`. When the removal failed (a permissions fault, a locked volume) the banner vanished while the marker
stood: the gates read the MARKER (13x F3, R3-2 — `markerGate`), so every round stayed held under no banner at all;
the Sync-now door's refusal ("press Resume Sync in the banner below", `LibraryOpenCopy.syncNowHeldRefusal`) pointed
at a banner that was gone; and the next launch came up held again with no explanation.

**The fix.** The press checks the answer: a marker that is still there keeps the hold, sets `resumeFailure` to
`LibraryOpenCopy.resumeMarkerNotRemoved` (PROVISIONAL words, **P-VX339-1**: "Sync is still waiting: Variorum couldn't
remove the restore marker beside your library. Press Resume Sync to try again."), and resumes nothing (the gates
would refuse the round anyway); a later press that removes it clears the line, the banner, and catches up once. The
banner (`RestoreHoldBar`, `LibraryOpenDoor.swift`) renders the line beneath its sentence, line-limited for the
window's minimum-size probe (the b6dae25 class). The clear is a seam on `RestoreHoldModel.init` (`clearMarker`,
defaulting to `LibraryRestoreHold.clear`) so the ticket's fake store can stand in; every existing caller is
byte-unchanged. Today's `RestoreHoldModel` only on the logic side; `LibraryRestoreHold` (core) untouched. VX-317 stays
open (the rebuild's phase 5).

**Pins** (`App/Variorum/VariorumTests/VX339ResumeHoldTests.swift`): `aClearThatFailsKeepsTheBannerSaysWhyAndResumesNothing`
(the ticket's fake hold store: banner kept, the line said, nothing resumed, the marker and the gate still held; then a
clear that works resumes once) · `aMarkerThatCannotBeRemovedKeepsTheBannerOnTheRealRoad` (no seam: a read-only folder
the marker cannot leave) — both expected RED on the red product. **RAN at the batch: 2 of 2 red on u1-red, green on
u1-fixed — as expected.**

### The Mac products (PREBUILT — the batch window runs `test-without-building` only)

Both built `build-for-testing` from `App/Variorum/`, scheme `Variorum`, destination `platform=macOS`, no custom
configuration (Debug):
- **FIXED:** `<home>/dev/variorum-vx-348/DerivedData/u1-fixed` (`Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`)
  — the tree at `cf194996b` (log `DerivedData/u1-fixed-build.log`).
- **RED:** `<home>/dev/variorum-vx-348/DerivedData/u1-red` — `cf194996b` with `StoreBackup.swift` at
  its pre-fix content (`git show 231b44d24:App/Variorum/Shared/StoreBackup.swift`) and `RestoreHoldModel.swift`
  behaviourally reverted (the seam kept; the press ignores the clear's answer, as before) — both files confirmed
  recompiled in its log (`DerivedData/u1-red-build.log`), the tree restored after. `BackupRetention.swift` stays
  fixed there (the old `StoreBackup` never calls its new function), so the pure guard compiles.
- **The commands** (under a held stage claim; confirm each "Test run with N tests" line):
  ```
  cd <home>/dev/variorum-vx-348/App/Variorum
  # RED — expect VX338: 4 of 5 fail (the pure guard passes); VX339: 2 of 2 fail
  xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-348/DerivedData/u1-red test-without-building -only-testing:VariorumTests/VX338SharedBackupFolderTests -only-testing:VariorumTests/VX339ResumeHoldTests
  # FIXED — the pins and their neighbours, all green
  xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-348/DerivedData/u1-fixed test-without-building -only-testing:VariorumTests/VX338SharedBackupFolderTests -only-testing:VariorumTests/VX339ResumeHoldTests -only-testing:VariorumTests/BackupRetentionTests -only-testing:VariorumTests/BackupRunTests -only-testing:VariorumTests/BackupSingleFlightTests -only-testing:VariorumTests/BackupOwnFilesTests -only-testing:VariorumTests/DataSafetyRunbookTests -only-testing:VariorumTests/BackupFutureStampTests -only-testing:VariorumTests/StoreBackupTests -only-testing:VariorumTests/SnapshotPairTests -only-testing:VariorumTests/LibraryPortabilityDoorTests -only-testing:VariorumTests/ChromeMinHeightTests -only-testing:VariorumTests/VX209GuideWarningTests
  ```
  A FIXED product built before a later unit's commits is still the U1 tree; the run's whole-batch product is the
  orchestrator's to rebuild at the end.
- **The phone target** builds with U1's `Shared/` changes (`xcodebuild -scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' build` — BUILD SUCCEEDED; no simulator booted, no test run).

### For the orchestrator's closeout (not U1's to apply)
- **AppSpec §9's standing conventions** may want one contract line: the operations layer stores no U+0000 (VX-357) —
  canon deltas are the closeout's, exactly as ruled.
- **The editor-seam finding** (VX-357 above): a null pasted into the live editor diverges from the stored take until
  re-render; the fix is the editor's insert door — a ticket or the editor-seam batch, Fable-reviewed.
- **The identity finding** (VX-357 above): a `clientInfo.name` (or an id) holding a NUL binds as its prefix on every
  SQL read and write — a candidate ticket for the MCP door.
- **The due-check finding** (VX-338 above): another Mac's fresh far copy answers this Mac's far due-check.
- **The PROVISIONALs for the merge's QUESTIONS bundle:** P-VX357-1…5, P-VX338-1…2, P-VX339-1.

## U1 ADJUDICATION (the orchestrator, 2026-10-18 — after spot-verification of every claim)

- **Verified:** tree clean and pushed; per-piece commits, each naming its member, no trailer anywhere; both prebuilt
  products exist with their xctestrun files and build logs; the pins and `Domain/StoredText.swift` on disk; the
  record's sections complete. Headless counts as reported.
- **VX-338's form — ACCEPTED, PROVISIONAL (P-VX338-1):** the implementer built a third form (the device-local
  own-copies list) instead of returning the fork first, which the constitution's proposal-first rule asks; under
  her overnight PROVISIONAL-and-continue mandate the adjudication is post-hoc and the deviation is RECORDED, not
  silent. On the merits the form stands: BOTH named forms leak past the two-file fence — the filename tag breaks
  the restore/key-file classifiers (core) and the Data Safety copy; the subfolder hides copies from the Castle
  switch's pre-switch listing in `PostureSwitch` (VX-378's lane, untouchable this window) — while the list form
  touches only the two named files and every failure mode errs toward KEEPING files. The Fable reviewer reads this
  member in particular (her word); the ladder re-examines the argument cold.
- **The one headless red** (`MCPHarnessTimeLimitTests…FailsTheConnectNamedAndBounded`, 18.7 s vs a 15 s bound at
  load 16–19, green alone 3/3) **is VX-353's standing class** (the known load-dependent timing flake) — recorded,
  not this run's.
- **The findings are tickets:** the editor-seam NUL divergence → **VX-395** (Medium, Editor, Fable-review-mandatory,
  out of this run's lane by its fence); the identity NUL prefix-bind → **VX-396** (Low, MCP); the far due-check
  reading every Mac's copies → **VX-397** (Low, Castle & sync, rides VX-302's rebuild design). All three triaged at
  mint per the labeling rule; none joins this run.
- **Next:** U1's Mac batch is READY with the coordinator (the record's `test-without-building` commands, red legs
  first); U5 (the urgent MCP trio) spawns now and builds headless while the batch waits for its window.

## U5 UNIT RECORD (VX-392 · VX-393 · VX-394 — the urgent MCP trio)

*Implementer: `opus-implementer` at xhigh, fresh session, 2026-10-18. Read in its own context before any code:
`notes/MCPSpec.md` in full, this plan in full (§U5 with her words, R-VX348-5/6 and the client-session report verbatim;
the build notes; the Environment traps; the kickoff sitting and her overnight mandate; the U1 record's VX-357 section),
`notes/SessionResiliencyProtocol.md`, CLAUDE.md + its canon. Lane: no `Sources/VariorumCore/Sync/`, custody, Keychain,
`Protection/`, synced schema or editor-seam line; grants are LOCAL-ONLY (their family may grow by a local migration).*

**NOT DONE BY THIS UNIT (first line, by the brief's rule):** no `xcodebuild test` and no walk (the brief: the stage is
the orchestrator's) — the Mac pins (`MCPConnectionEndDoorTests` ×3, `MCPWingFacesTests.listWingsSpeaksItsOwnWords`) are
written, compiled, and their red and fixed products PREBUILT from the folded tree (the commands at the end of this
record), their run PENDING the batch; VX-392's done-when real-client live round on the dev store is PENDING a stage
window (its exact steps in VX-392's section); no faces were walked (the only face change is the Activity list's words).
VX-394's remainder — whether a connected AI's work should count as "use" for Castle's lock after time away — is HER
call (author-only; options recorded), not built.

### LIVE STATUS (per member)

- **VX-392 (an empty granted wing can't be discovered):** DONE (`7998e88a5`) — FIXED: `list_wings` (R-VX348-5) with
  its pins, 5 of them verified RED on the pre-fix tree, all 8 green after; the descriptions point at it; the
  non-empty wing road and the empty-book-alone road proven by guards (green on both sides — those halves HOLLOW,
  recorded). **PENDING:** the Mac pin's run (`listWingsSpeaksItsOwnWords` — compile at the unit's Mac seam) and the
  real-client live round (its steps in the VX-392 section). Its section below.
- **VX-393 (duplicate grant rows for one client × target):** DONE (`00c754151` the schema · `98c88a686` the op) —
  FIXED: traced (the one mint, `insertMCPGrant`, never looked at the place's existing row; every road but Change…
  added one); pins verified RED on the pre-fix tree (`DerivedData/u5-logs/vx393-red.log`: 7 of 8, the
  other-clients guard green), 8 of 8 green after; the whole headless suite green after the op change (MCP 376/70,
  core 2916/340, the third target 40/6). Its section below.
- **VX-394 (mid-session disconnect while the pane says running):** DONE (`6306a21ff` the core + host · `0784d8b9a`
  the app side) — the mechanism ESTABLISHED by code reading as a definite kill path (the library's LOCK under Castle —
  sleep · screen lock · ten minutes of time away counted from HER use only — detaches the door and hangs up every
  connection; App Nap, socket idle timeouts, the path and the SDK loop ruled out); whether it was HER night's cause is
  not provable from here. The Activity drop line SHIPPED; its headless pins verified red on a behavioural revert (4 of
  6, the guards green), 6 of 6 green. **The batch's one red (live-confirmed: her switch OFF wrote no line) is FIXED
  by the fix leg `0ebf5c926`** — its section below; **PENDING:** `theDoorsTwoStopRoadsSayTheirReasonsOnce`'s re-run on
  the prebuilt `DerivedData/u5-fix` (the rest of the batch was green). The
  ticket's remainder is HER call (does a connected AI's work count as "use" for Castle's lock after time away? — an
  author-only lock relaxation, recorded with options, not built). Its section below.
- **No behavioural revert is in flight.** The Mac red product's reverts (`MCPPaneCopy.swift`, `MacWillLock.swift`,
  `MCPServerHost.swift` over the committed `0784d8b9a`) were built into `DerivedData/u5-red` — all three files confirmed
  recompiled in its log — and restored by `git checkout --`; `git diff` clean after.
- (VX-394's headless red leg ran and was restored: `MCPServerHost.swift` reverted over
  the committed `6306a21ff` — the end-line write and `recordConnectionEnds`'s body removed — 4 of 6 pins RED, the two
  guards green, `DerivedData/u5-logs/vx394-red.log`; restored by `git checkout --`, `git diff` clean, 6 of 6 green.)
- **THE FOLD (the orchestrator's instruction, her word via the coordinator):** IN — `460d39785` merges main
  `d8bb24488` (VX-381's `d4b104e8a` + Castle's `aeabdd75b` + two notes-only commits) into the branch after
  `98c88a686`, cleanly (no conflict). The incoming delta shares ONE file with this branch's touched set,
  `Sources/VariorumCore/Operations/Operations+Tag.swift` (U1's VX-357 strip ⇄ VX-381's tag undo) — auto-merged;
  `Shared/OpsRefusalTable.swift`: NOT touched by this branch (no). No incoming migration (`v1_30` stays this run's).
  Re-run on the folded tree: `swift build --build-tests` green; the core target whole, 3248 tests / 418 suites green
  (Castle's suites included). Every Mac product this unit prebuilds is built FROM the folded tree (the coordinator's
  Castle-phase-2 addendum — none was built before the fold).

### VX-392 — `list_wings`: a granted wing is discoverable, empty or not

**The trace (inputs → wrong state).** A client approved with `edit · always` on a wing that holds no note and no book
has, before this fix, exactly four roads to a wing id, and none of them names that wing: `list_books` selects readings
whose resolved wing is a granted wing (`MCPReadTools.listBooks`, the `json_each(:wings)` arm) — an empty wing has no
reading row to return; `list_notes` with no argument pages each granted wing's notes (`sharedPage` →
`recencyPage(wingID:)`) — an empty wing has no `container` row; `search` reaches a wing's notes and books only through
their rows (`reachedScopes` → `searchPassages`); `list_my_activity` answers only the caller's own logged acts. Every
wing-scoped write (`create_note` / `import_document` with `wing_id`, `create_book`, `move_note_to_wing`) needs the id
up front (`MCPWriteTools.inWing` decides on it). So the client could never make its FIRST write into a wing it was
explicitly granted — the report's critical, exactly (her workaround: hand-add a note so its `wing_id` leaks through
`list_notes`). Not a rule gap: `decideWing` allows the write the moment the id is known.

**The fix (her R-VX348-5, as built).**
- `list_wings` (`MCPToolCatalog.listWings`, read rung, scope `[.wing]`; handler `MCPReadTools.listWings`): every wing the
  client holds a LIVE grant on, Home first, then the switcher's order (`wing.position`); per wing `wing_id`, `name`,
  `rungs` (the cumulative rungs of its strongest live grant there), `duration` (of the grant `decideWing` itself would
  authorize at that rung — read OFF the rule, never a parallel one), `grants` (every live grant held there, strongest
  first: `rung`, `duration`), and `notes` / `books` / `gatherings` — counted exactly as `list_notes(wing_id:)` and
  `list_books` list them at rest: each note through `decide` on batched `mcpNoteFacts` (500 per batch), each book
  through `decide`, each gathering through `decideGathering`; archived ones aside (both listings' resting posture).
- The answer's whole domain is the client's own grants, so no oracle arises: an ungranted wing, a wing deleted since
  its grant, and a wing reached only through a book or note grant inside it are all simply absent (pinned).
- **Listed only by a live wing grant** — a new `MCPToolDeclaration.grantOnly` flag skips the open-book clause of
  `isListed` (PROVISIONAL **P-VX392-3**); called anyway (the list is a courtesy, the rule the boundary) it answers
  `{"wings": []}`.
- Logged like every listing (F3: one read snapshot, then the activity line in its own short write; target-less);
  Activity speaks it (`MCPPaneCopy`: "listed its shared wings", refused: "listing its shared wings" — PROVISIONAL
  words, VX-234's pass). `list_my_activity` lists it only under `include_reads` (it is a read — automatic, the
  catalog-derived act list).
- **The AI's docs:** `create_book`, `create_note`, `import_document`, `list_notes`, `move_note_to_wing` and
  `show_in_app` (its `wing_id` input) each say `list_wings` gives the wing id; `list_books` says an empty wing lists
  nothing there and points at `list_wings`; pinned so a future wing-taking tool must say it too.
  `MCPSession.instructions` is UNTOUCHED (the brief's rule: only if a sentence there became untrue — none did; see
  P-VX392-5 for the ruling's letter).
- P1: ∝ the GRANTED wings — each wing's readings (shelf-scale) and its own notes' facts, batched; the wing filter rides
  `container`'s scan exactly as `list_notes(wing_id:)` does today (no index on `container.wing_id` exists; adding one is
  synced-schema DDL, out of this lane — recorded, not built).

**The neighbouring claims, each traced (the report's "also check" and her framing):**
- *An empty BOOK granted on its own:* `list_books` already lists it (its `bookIDs` arm), with `wing_id` and
  `notes: 0`, and `create_note(book_id:)` lands in it — guard `anEmptyBookGrantedAloneIsListed`, GREEN on the pre-fix
  tree too: **that half is HOLLOW** (nothing fixed; R-VX348-5's "list_books also fixed" had nothing to fix).
- *A wing with gatherings but no books:* `list_books` already lists the gathering (kind `gathering`) with the wing's
  id (VX-273) — the `list_books` half of `aWingWithOnlyAGatheringIsReadThroughBothListings` was green before; its
  `list_wings` half is new.
- *Her framing, "even when there's a whole wing grant, claude can't see it or write in it", for a wing that HOLDS
  things (no Home grant at all):* every listing surfaces its notes and books (`list_notes()`, `list_notes(wing_id:)`,
  `list_books`, `search`), and each rung writes exactly what it should there (read refuses `create_note` with the
  rung sentence; write new lands a note and a book and refuses `edit_take`; edit rewrites her take) — guard
  `aWingGrantSurfacesItsNotesAndBooksAndWritesAtTheRightRungs`, GREEN on the pre-fix tree: **the non-empty road was
  never broken; the empty wing was the whole gap.** (Her screenshot's duplicate rows are VX-393's, below.)

**Pins** (`Tests/VariorumMCPTests/MCPListWingsServerTests.swift`; RED-ON-OLD verified on the pre-fix tree — the new
file built against the tree before the fix, `DerivedData/u5-logs/vx392-red.log`: 5 failures, each "Unknown tool" /
"list_wings" not listed; `vx392-green.log`: 8 of 8 green after):
`aFreshClientGrantedAnEmptyWingFindsItInOneCallAndMakesABookThere` (the done-when, headless: ONE call finds the wing,
`create_book` lands in it, the count follows) · `onlyTheClientsOwnWingGrantsAreListed` (book- and note-reached wings,
ungranted, deleted, revoked and the open book alone all absent; the tool unlisted with no wing grant) ·
`theCountsAreWhatTheListingsList` (a Private note and book, an archived note and book never count; the counts equal
the listings') · `aOnceWingGrantIsListedAndTheListingSpendsNothing` — all RED on old; guards
`anEmptyBookGrantedAloneIsListed`, `aWingWithOnlyAGatheringIsReadThroughBothListings` (its `list_books` half),
`aWingGrantSurfacesItsNotesAndBooksAndWritesAtTheRightRungs` (green on both sides by design — the hollow halves) and
`everyToolThatTakesAWingIDSaysWhereItComesFrom` (the docs). Justified edits (the ritual): `MCPServerTests`' catalog
walk (the read set gains `list_wings`) and `MCPWriteServerTests`' completeness subtraction (it names no note, block or
take). Mac pin `MCPWingFacesTests.listWingsSpeaksItsOwnWords` — written; its run PENDING the batch (red on old: the
fallback said "used list wings").

**PROVISIONAL (for the merge's QUESTIONS bundle):**
- **P-VX392-1** — the answer's shape (keys `wing_id`, `name`, `rungs`, `duration`, `grants`, `notes`, `books`,
  `gatherings`; Home's `wing_id` is `""`). Alternatives: (b) the report's other option, a `wings` array on
  `list_books` (not chosen — her pick was the tool); (c) no `grants` array (simpler, but a once grant beside a standing
  one would go unsaid).
- **P-VX392-2** — a live ONCE wing grant is listed (the ruling says "standing wing grant"; read here as "a grant the
  client holds on the wing itself": a listing never spends a once grant, and an unlisted once wing grant could never be
  used — the very gap). Alternative: (b) standing grants only (once wing grants stay undiscoverable when empty).
- **P-VX392-3** — the open book alone neither lists the tool nor answers any wing (it is a switch, not a grant on a
  wing; it holds no write). Alternative: (b) under the open book, list every live wing at `read` with `via:
  open_book`.
- **P-VX392-4** — the duration tokens `once` · `until_disconnect` · `always` (the advice's "until you disconnect" as a
  token; the store says `connection`). Alternative: the stored words.
- **P-VX392-5** — `MCPSession.instructions` untouched, by the brief's rule (no sentence became untrue; 2,969 of its
  3,000 characters are used). R-VX348-5's letter says "the instructions and the create_book/create_note docs point at
  it" — the docs do; the smallest instructions pointer that fits is " (list_wings lists yours)" after "Each names a
  note, a book or a wing" (2,994 / 3,000), left for the orchestrator's or her call.

**The real-client live round (the done-when — PENDING a stage window; the orchestrator drives it):**
1. Under a held stage claim, run the Debug dev-store build from this branch (`io.lduarte.Variorum.debug`), Settings ▸
   MCP ▸ the server ON; the dev Claude Code client (`variorum-dev`) approved (re-run its setup from the Claude Code tab
   if its key is stale).
2. ⌘L ▸ new wing "U5 empty wing" — nothing in it.
3. Settings ▸ MCP ▸ Shared with AI ▸ Share… — WHO the client, WHERE the wing, `read, suggest, write new and edit ·
   always`.
4. In a FRESH Claude Code session with no prior context, ask only: *"A wing called 'U5 empty wing' is shared with you
   in Variorum. Make a book called 'first book' in it."* Expected: the client calls `list_wings` (one call), takes the
   wing_id, calls `create_book` — it lands; ⌘L to the wing shows "first book" on its Bookcase.
5. Captures (into the run's screens folder): the client's transcript of the two calls; Settings ▸ MCP ▸ Activity
   showing "… listed its shared wings" and "… made the book “first book”" in BOTH voices.

### VX-393 — one grant row per client × place (upgrade in place)

**The trace (inputs → wrong state).** Every grant the store holds is minted by ONE private function,
`Operations.insertMCPGrant` (`Operations+MCPGrants.swift`), which validated the scope and INSERTed — it never read what
the client already held on that place. The roads that reach it: the grant sheet's confirm
(`MCPDoor.grant` → `grantMCPAccess(_:_:replacing:)` with `replacing: []` whenever the sheet was opened fresh — the
pane's Share…, a place-door, ⌘L's wing row), ⌥⌘A (`shareThisNote` → `grantMCPAccess(_:_:)`), an ask's answer
(`MCPDoor.answer` → `grantMCPAccess(_:_:)`), Allow AI here (a once grant), approve-with-grant
(`approveMCPClient(_:granting:)`, which "only adds the grant" on an approved client) and the bulk share
(`grantMCPAccess(_:notes:…)`). Only Change… named rows to replace (`revokeReplacedMCPGrants`). So sharing a place a
second time from any fresh sheet — her `read · always` on PlanetLillian, then the sheet again at `read, suggest,
write new and edit · always` — ADDED a second live row; Shared with AI (`Queries.mcpSharedGroups`, one row per live
grant act) listed both; revoking the edit row left the read row standing, silently. Not re-approval and not separate
sessions (neither mints a grant): the minting road is the grant sheet's new-grant confirm, which every place-door and
the pane share.

**The fix (her R-VX348-6, as built).**
- **At the one mint:** a STANDING spec (while connected · always) first revokes the client's live standing row on the
  same scope kind × id — on the act's own stamp, in the act's transaction — then inserts. Every road inherits it; no
  door changed. A once spec revokes nothing (P-VX393-3).
- **The schema, its own commit ahead of the op (`00c754151`):** `v1_30_mcp_one_grant_per_place` — LOCAL-ONLY, the
  v1_24–v1_29 road (no `sync_version`, no trigger, nothing pushed, marker 13, the export keeps the family empty):
  (1) the merge (`MCPGrantSchema.v1_30MergeSQL`) keeps each client × place's first-ranked live standing row — an
  "always" row before a while-connected one, then the higher rung, then the newer `created_at`, then the larger id —
  and revokes the rest on one stamp, never deleting; (2) `uq_mcp_grant_standing_place`, a partial unique index on
  `mcp_grant(client_id, scope_kind, scope_id) WHERE revoked_at IS NULL AND duration IN ('connection','always')` — the
  store itself refuses a second standing row, so a future road that forgets the replace fails loudly instead of
  duplicating (DB-backed, the invariant's house style). Once rows and revoked rows stand beside it freely.
- The faces need no change: the pane draws one row per live grant, and there is now one per place; a receipt's
  Revoke › names the act's grant ids, which are the place's one row.

**Pins** (`Tests/VariorumCoreTests/MCPOneGrantPerPlaceTests.swift`; RED ON OLD verified on the pre-fix tree —
`vx393-red.log`; 8 of 8 green after — `vx393-green.log`):
`aNewGrantOnASharedPlaceReplacesItsRowOnEveryRoad` (each minting road — the plain op, the sheet's
`replacing: []`, approve-with-grant, the bulk share — on a wing, a book and a note: one live row, the new one; Shared
with AI shows each place once) · `aLowerOrShorterGrantReplacesTooAsChangeDoes` · 
`changingAGrantToAnotherPlaceReplacesThatPlacesRowToo` · `revokingThePlacesOneRowLeavesNothingBehind` (before: the
earlier `read` row stood on) · `aOnceGrantNeitherReplacesNorIsReplaced` · 
`aStoreWithDuplicateGrantsKeepsEachPlacesStrongestAtTheMigration` (her screenshot's wing pair and the book pair, a
while-connected row beside an always one, two while-connected rows, a once grant, a revoked row and another client's
row — each as ruled) · `theFamilyHoldsOneStandingGrantPerPlaceByConstruction` (the index refuses a second live
standing row; a once and a revoked row stand beside it; local-only) — all RED on old; guard
`oneRowPerClientAndPlaceNeverAcrossThem` (green on both sides by design). Justified edit (the ritual):
`MigrationTests`' index lists gain `uq_mcp_grant_standing_place`. No existing pin relied on the additive behaviour
(the whole headless suite stayed green).

**PROVISIONAL (for the merge's QUESTIONS bundle):**
- **P-VX393-1** — a new standing grant replaces the place's standing row IN FULL, its duration included — the
  ruling's letter ("REPLACES the row (the Change… sheet's semantics applied to every grant road)"). The consequence,
  said so she can rule otherwise: answering an ask "until it disconnects" (or ⌥⌘A's while-connected grant) on a place
  that held an "always" grant at a lower rung leaves NOTHING there once the client disconnects. Alternatives: (b) when
  the new grant is shorter-lived than the row it replaces, keep the longer row too (two rows — the duplicate class
  again, but each saying why); (c) the ask sheet and ⌥⌘A's receipt say "replacing its read · always grant" when they
  replace a longer one (a face line — her copy pass).
- **P-VX393-2** — the migration's merge order when durations differ: an "always" row is kept over a while-connected
  one even at a lower rung (the brief's natural reading — "the stronger rung with its own duration" — would keep
  `edit · until it disconnects` over `read · always`; but a while-connected row cannot be serving anything when a
  migration runs — the store opens before the door, and every server start revokes every while-connected row — so
  that reading would leave her NOTHING on the place after the first start). Among standing rows of one duration the
  strongest rung wins, then the newest. Alternative: (b) the brief's reading.
- **P-VX393-3** — once grants are outside the one-row rule (an act-scoped permission, not a standing row): a once
  grant beside a standing one is shown as its own row ("· once") and spent by its one act. Alternative: (b) a new
  standing grant also revokes the place's pending once grants.

### VX-394 — a mid-session disconnect while the pane says "running"

**The trace (investigation first — every claim below read in the code, none run against her library).**
1. *What "MCP server disconnected" is.* For a stdio server, Claude Code says it when the server's process exits — here
   the `variorum-mcp` shim. The shim (`MCPShim.pump`) copies stdin → socket on a helper thread and socket → stdout on
   its own; it returns, and the process exits, only when the socket → stdout copy ends: the APP closed or shut down the
   socket (EOF), a read error, or a stdout write failure. Nothing in it times out (no `SO_RCVTIMEO` on the pumped
   socket).
2. *When the app ends a connection.* A session (`MCPSession.run`) ends only when its reader
   (`MCPSocketTransport.readLines`) returns: EOF or an error from the peer (the client's own end), a line past the
   16 MiB cap (answered, then closed — VX-184 U1), or the host's `stop()` → `hangUp()` (`shutdown(SHUT_RDWR)`). The SDK's
   loop (swift-sdk 0.12.1, `Server.start`) catches every per-message error and answers it, so no message can end it.
3. *When the host stops.* Only from the door (`MCPDoor`): the switch OFF (`reconcileServer`), and `detach()` — called
   by the library's LOCK road (`AppBootstrap.lock` → `onWillLock` → `macWillLock` → `stopServices` →
   `appDelegate.mcp.detach()`), by an adoption or a re-key (`adoptLibrary` / `rekeyLibrary`, the same `onWillLock`), and
   by a new session's `attach`. A locked library serves no one BY DESIGN (A-8): locking closes the encrypted store and
   drops its key, so there is nothing a server could read.
4. *The definite kill path that fits every fact in her report.* Under CASTLE (`effectiveGate.isDemanded`; Standard is
   `.auto` and never re-locks), `ProtectionController.startRelockMonitors` locks the library on
   `NSWorkspace.willSleepNotification`, on `com.apple.screenIsLocked`, and — checked every 30 s — once
   `IdleLockClock.isDue(lastUsedAt, relockAfterIdleMinutes)` (default 10 minutes) holds, where `lastUsedAt` is stamped
   ONLY by her own use of Variorum (`noteActivity`: the local event monitor's key/mouse events, ready, became-active) —
   never by an MCP client's calls. So: an AI session working on its own, ten minutes after her last keystroke or click in
   Variorum (or the screen locking at 3–4 AM), locks the library → the door detaches → the server stops and hangs up
   every connection → the shim reads EOF and exits → "MCP server disconnected". At her next unlock the door re-attaches
   and starts the server again → the pane says "running · socket in the app container". Her `/mcp` reconnect then
   works, "always" grants survive, and "until it disconnects" grants are gone (the start sweep) — exactly her report.
   (Her real library is in Castle per her VX-266 rehearsal plan, "her real Castle account"; the dev store is too — for
   her to confirm.)

**Ruled out, each with its reason:**
- *App Nap / idle throttling* — App Nap throttles timers and lowers priority; it closes no socket. The accept loop blocks
  in `poll`, each reader in `read`, and both wake on I/O whatever the nap; the shim is a command-line child of the client,
  never napped. A napped app answers later — it never disconnects. So a `ProcessInfo.beginActivity` keep-alive would not
  touch this drop: **NOT built** (the hallucination guard — no speculative keep-alive).
- *Socket idle timeouts* — none exists: a unix stream socket has no idle timeout, and no receive timeout is set on a
  served connection (only on the over-cap refusal's helper thread) or on the shim's pumped socket.
- *The socket path across restarts or sleep* — fixed (`<container>/Data/mcp.sock`); an accepted connection never reads
  the path again, and a restart rebinds the same one — it changes only NEW connections, which find it (her reconnect
  worked).
- *A message that kills the SDK's loop* — none can (point 2).
- *Sleep without Castle* — processes freeze; a unix socket survives the wake.

**Not established:** which of the Castle triggers ended HER session (the idle lock, the screen lock, sleep), or that her
library was in Castle that night, or — had it been Standard — whether the client itself restarted. That is what the drop
line now answers.

**The fix that ships (observability — "ships regardless").** Each connection that named itself (admitted past the setup
key, its `initialize` read — `clientName`'s rule) leaves ONE line in the activity log when it ends, its act one of
`MCPConnectionEnd`'s four (`Domain/MCPConnectionEnd.swift`): `disconnect_client` (the client's side closed — the server
still running), `disconnect_library_closed` (the library locked or closed), `disconnect_server_off` (her switch),
`disconnect_over_limit` (a message past the cap).
- *The host* (`MCPServerHost`): `stop(ending:)` marks every live session with its reason before the hang-up; a session's
  end (`ended`) writes its line — the stop's reason, else the over-cap answer (the transport's flag), else the client's
  close — once (`MCPSession.claimEndLine`); `recordConnectionEnds(_:)` writes every live connection's line in ONE write,
  NOW, and the hang-up that follows never says them again.
- *The lock road* (her report's case — the store is about to close, and a line written by a session's own end races the
  pool's close): `macWillLock` gains an `endingConnections` step, run AFTER every note's leaving savepoint and BEFORE the
  services stop (the ruled order otherwise untouched; a no-op by default, so the phone and every pin wire what they
  wired); `VariorumApp` passes `MCPDoor.recordLibraryClosing()` — the host's record, off the main thread (P2), awaited.
  Adoption and re-key ride the same road. The door's `detach` stops with `.libraryClosed`, its switch-off with
  `.serverOff`.
- *The face:* Settings ▸ MCP ▸ Activity speaks the four (`MCPPaneCopy.connectionEndPhrase`, PROVISIONAL words):
  "‹client› disconnected" · "‹client› was disconnected when the library locked or closed" · "… when the MCP server was
  turned off" · "… after a message over the size limit" — with "(N times)" when a run coalesces.
- No sync, custody, Keychain or `Protection/` line: the relock monitors are read, never changed; `ProtectionController`
  and `AppBootstrap` are untouched.

**The author's call this leaves (NOT built — relaxing a lock is author-only, CLAUDE.md):** the drop is the design working
(A-8). Her one lever: *should a connected AI's work count as using Variorum for Castle's "Lock after time away"?* Options
for the QUESTIONS bundle: (a) as built — only her own use holds the library open; an AI session ends when the library
locks, and Activity now says so; (b) a connected client's calls count as use (the idle lock never fires mid-session;
sleep and the screen lock still lock — a weaker lock while an AI works); (c) a Castle dial, "Stay unlocked while an AI
client is connected", default off. And a docs half for her copy pass: `MCPSession.instructions` could tell the model "if
Variorum's tools vanish, the library may have locked — tell the author; reconnect once they unlock it" (the advice is at
2,969 of 3,000 characters — it would need room made). **Ticket disposition (the orchestrator's):** the mechanism is a
definite, by-design path and the drop line ships; I recommend VX-394 stays OPEN as "Needs Lillian" on the lock question
(or closes with a ticket minted for it).

**Pins.** Headless — `Tests/VariorumMCPTests/MCPConnectionEndServerTests.swift`:
`aClientThatClosesItsConnectionLeavesOneLineSayingSo` · `theServerSwitchedOffEndsEveryConnectionAndSaysSo` (two
clients) · `theLibraryClosingIsSaidBeforeTheStoreGoesAndNeverTwice` · `aMessageOverTheCapEndsTheConnectionAndSaysSo` —
RED ON OLD by a behavioural revert of `MCPServerHost.swift` over `6306a21ff` (the end-line write and
`recordConnectionEnds`'s body removed: 4 of 6 red, `vx394-red.log`), restored, 6 of 6 green; guards
`aConnectionThatNeverNamedItselfLeavesNoEndLine` (a bare shim, a connection that never initializes) and
`theEndActsAreNoClientsActs` (never a catalog tool, never in `list_my_activity`). Mac —
`App/Variorum/VariorumTests/MCPConnectionEndDoorTests.swift`: `theDoorsTwoStopRoadsSayTheirReasonsOnce` (a real host
behind the door: her switch OFF says "server off"; the lock road's record then its detach say "library closed" ONCE),
`theLockRoadSaysTheConnectionsEndAfterTheSavepointsAndBeforeTheStop` (the ruled order with the new step),
`aConnectionsEndReadsInWords` — written, compiled (`build-for-testing` green), their run PENDING the batch (red product
below).

**PROVISIONAL (for the merge's QUESTIONS bundle):**
- **P-VX394-1** — the four lines' words (her copy pass, VX-234).
- **P-VX394-2** — one line per CONNECTION (a client with two connections open logs two); alternative: one per client.
- **P-VX394-3** — the client's own close is logged too (every end, not only Variorum's) — it is what tells "the client
  ended it" from "Variorum did"; alternative: only Variorum-side ends (fewer lines).
- **P-VX394-4** — `list_my_activity` never lists the end lines (`MCPOwnActivity`'s rule for every connection row);
  alternative: list them, so a reconnecting client can learn why it was dropped.
- **P-VX394-5** — a QUIT logs nothing (the process ends with the store; a client's next connect hears "Variorum must be
  open" — VX-181); alternative: a line from `applicationShouldTerminate`'s road (its cancel arm makes that fiddly).
- **P-VX394-6** — a pending connection request's end is logged too (it named itself); alternative: approved clients only.

### U5's suites (headless, at the end — the folded tree)

`swift test` whole on the final tree: VariorumCoreTests **3248 tests / 418 suites passed** (Castle's suites ride the
fold); the third target **40 / 6 passed**; VariorumMCPTests **382 / 71 with ONE failure**,
`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (≈19 s against its 15 s bound
at a load average of 10–16 — other sessions' builds), **green alone (3 / 3, 2.1 s)** — VX-353's standing load-dependent
flake (a fake peer, not the host this unit changed). The VX-180 / VX-181 no-regress suites, run on the final tree:
`MCPDiscoverProbeServerTests`, `MCPShimClosedAppTests`, `MCPPreInitializeWindowTests`, `MCPShimTests` — **30 / 4 green**
(the closed-app sentence and the mid-session connect-once-the-app-opens unchanged). The phone target builds with U5's
core changes (`xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build` — BUILD SUCCEEDED;
no simulator, no test run).

### The Mac products (PREBUILT from the FOLDED tree — the batch window runs `test-without-building` only)

Both `build-for-testing` from `App/Variorum/`, scheme `Variorum`, destination `platform=macOS`, Debug (no custom
configuration), each AFTER the fold (`460d39785` is in both products' history — the coordinator's Castle-phase-2
addendum):
- **FIXED:** `<home>/dev/variorum-vx-348/DerivedData/u5-fixed`
  (`Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`) — the code at `0784d8b9a` (log
  `DerivedData/u5-fixed-build.log`, TEST BUILD SUCCEEDED).
- **RED:** `<home>/dev/variorum-vx-348/DerivedData/u5-red` — `0784d8b9a` with `MCPPaneCopy.swift` (no
  `list_wings` words, no `connectionEndPhrase`), `MacWillLock.swift` (no `endingConnections` call) and
  `MCPServerHost.swift` (no end lines) behaviourally reverted, the three confirmed recompiled in
  `DerivedData/u5-red-build.log`, the tree restored after.
- **The commands** (under a held stage claim; confirm each "Test run with N tests" line):
  ```
  cd <home>/dev/variorum-vx-348/App/Variorum
  # RED — expect MCPConnectionEndDoorTests 3 of 3 red; MCPWingFacesTests: listWingsSpeaksItsOwnWords red, the rest green
  xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-348/DerivedData/u5-red test-without-building -only-testing:VariorumTests/MCPConnectionEndDoorTests -only-testing:VariorumTests/MCPWingFacesTests
  # FIXED — the pins and every MCP-door / grants / lock-road neighbour, all green
  xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-348/DerivedData/u5-fixed test-without-building -only-testing:VariorumTests/MCPConnectionEndDoorTests -only-testing:VariorumTests/MCPWingFacesTests -only-testing:VariorumTests/MacWillLockTests -only-testing:VariorumTests/AutosaveRegistryLifecycleTests -only-testing:VariorumTests/LandingOffsetTests -only-testing:VariorumTests/MCPPaneTests -only-testing:VariorumTests/MCPPaneTabsTests -only-testing:VariorumTests/MCPHerEditorDoorTests -only-testing:VariorumTests/MCPShareFacesTests -only-testing:VariorumTests/MCPSharedRowsTests -only-testing:VariorumTests/MCPSharedIconClickTests -only-testing:VariorumTests/MCPGrantSheetTests -only-testing:VariorumTests/MCPAskAndReceiptTests -only-testing:VariorumTests/MCPAsksWaitTests -only-testing:VariorumTests/MCPRebindFaceTests -only-testing:VariorumTests/MCPSetupKeyFacesTests -only-testing:VariorumTests/MCPSetupTabKeyTests -only-testing:VariorumTests/MCPSetupMenuTests -only-testing:VariorumTests/MCPEditFacesTests -only-testing:VariorumTests/MCPEditParityFacesTests -only-testing:VariorumTests/MCPLibraryParityFacesTests -only-testing:VariorumTests/MCPDeliberateFacesTests -only-testing:VariorumTests/MCPDoorErgonomicsFacesTests -only-testing:VariorumTests/MCPDuplicateFilingFacesTests -only-testing:VariorumTests/MCPCompareLandingTests -only-testing:VariorumTests/MCPNavigationTests -only-testing:VariorumTests/MCPGatheringIconTests -only-testing:VariorumTests/BookPanelMCPMarksTests -only-testing:VariorumTests/MCPWireRefusalSweepTests -only-testing:VariorumTests/TutorialMCPChapterTests -only-testing:VariorumTests/VX206ProtectionLandingTests
  ```
  Anything the batch finds red in the FIXED leg that the headless suites did not (the grants faces reading two rows
  where one now stands, say) is a revealed dependency of VX-393's one-row rule — say so to the orchestrator, never
  re-add the duplicate.

### For the orchestrator (not U5's to apply)
- **The PROVISIONALs for the merge's QUESTIONS bundle:** P-VX392-1…5, P-VX393-1…3, P-VX394-1…6.
- **Her call (author-only):** VX-394's lock question (a connected AI's work as "use" for Castle's lock after time away —
  options (a)/(b)/(c) in VX-394's section); my recommendation is that VX-394 stays open as "Needs Lillian" on it.
- **P-VX392-5:** R-VX348-5's "the instructions … point at it" — the docs do; the instructions are untouched by the
  brief's rule (the 25-character pointer that fits is in VX-392's section).
- **The real-client live round** (VX-392's done-when — steps in VX-392's section); it can also watch VX-393's one row
  (share the wing twice from a fresh sheet: Shared with AI shows it once) and VX-394's line (quit the client: "…
  disconnected"; lock the dev library: "… was disconnected when the library locked or closed").
- **AppSpec §7's grants-family line** may want `v1_30` named beside v1_24→v1_29 (a canon delta — the closeout's).


### VX-394 fix leg — the stop roads' end line (the batch's red, live-confirmed)

*The same implementer, resumed 2026-10-18 at the orchestrator's word (relayed by the coordinator) after the U5 batch:
`theDoorsTwoStopRoadsSayTheirReasonsOnce` red on the FIXED product (`ends == []` after her switch OFF), and live on
the dev store a held, initialized connection died at the pane's switch-off with NO Activity line, while the client's
own close did write. Only my own files committed (U2's uncommitted work shares the tree).*

**The trace (inputs → wrong state).** Her switch OFF → `MCPDoor.setEnabled(false)` → the snapshot observation →
`reconcileServer` → `stopServer(ending: .serverOff)`, which calls `host?.stop(ending: .serverOff)` and then `host = nil`
in the same breath. The door held the host's ONLY strong reference (the accept thread, the grants observation and each
session's task capture it `[weak self]`), so the host was deallocated right there — while its sessions were still
finishing their hang-up. Each session's end ran through the host: `serve`'s task did
`await session.run(); if let self { self.ended(session) } else { session.closeConnection() }` — with the host gone, the
`else` arm only closed the descriptor, and `ended()` (where the end line was written) never ran. So the reason, marked on
the session by `stop(ending:)`, was never written. The headless pins passed because the harness holds its host strongly
for the whole test (`ServerHarness.host` is a `let`); the client's own close wrote live because the host was alive
then. The lock road was NOT affected in its line (`recordLibraryClosing` writes BEFORE the detach, with the host alive)
— only the stop roads that let go of the host: her switch, and a detach not preceded by the record (a new session's
`attach`). (Pre-existing, recorded not fixed: the same `else` arm also skips `endMCPConnectionGrants`, so a door stop
leaves "until it disconnects" grants to the next server start's sweep — which revokes them before any connection can
use them.)

**The fix (on the traced mechanism).** The end line no longer depends on the host's lifetime: `MCPSession.writeEndLine()`
claims the line once and writes it through the session's OWN `database` and `operations` (it always held both), on its
own task (off main, P2). `ended()` calls it where it used to write, and the `else` arm (host already let go of) calls it
after `closeConnection()`. Quiet when the store is already gone (the lock road said it first). Nothing else moved: the
host stays weakly captured, the door unchanged.

**Pins.** NEW headless `MCPConnectionEndServerTests.aStopThatLetsGoOfItsHostStillSaysEachConnectionsEnd` — a host of its
own, started, a raw keyed client initialized, then the door's two lines (`stop(ending: .serverOff)`; `host = nil`),
asserting the host IS gone and the line lands: **RED on the pre-fix tree** (`DerivedData/u5-logs/vx394-fix-red.log` —
the host deallocated, no line), **green after** (`vx394-fix-green.log`; the suite 7 / 7). The whole MCP target after the
fix: **383 tests / 71 suites, ALL green** (`mcp-after-fixleg.log`, load ~25 — VX-353's flake passed this time). The
batch's Mac pin is the proof on the real door.

**The Mac product for the re-run (PREBUILT, stage-free):** `<home>/dev/variorum-vx-348/DerivedData/u5-fix`
(`Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`, log `DerivedData/u5-fix-build.log`, TEST BUILD
SUCCEEDED) — built from a CLEAN scratch worktree checked out at `0ebf5c926` (detached, removed after), so U2's
uncommitted files in the shared tree are NOT in it; the fold is in its history; `MCPSession.swift`,
`MCPServerHost.swift` and `MCPConnectionEndDoorTests.swift` confirmed compiled from that checkout. **The batch window
runs** (a held stage claim; confirm the "Test run with N tests" line):
```
cd <home>/dev/variorum-vx-348/App/Variorum
xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath <home>/dev/variorum-vx-348/DerivedData/u5-fix test-without-building -only-testing:VariorumTests/MCPConnectionEndDoorTests -only-testing:VariorumTests/MCPPaneTests -only-testing:VariorumTests/MCPHerEditorDoorTests -only-testing:VariorumTests/MacWillLockTests
```
Expected: all green — `theDoorsTwoStopRoadsSayTheirReasonsOnce` included (its switch-off arm now writes `serverOff`;
its lock arm says `libraryClosed` once). The live re-check, if a window allows: hold an initialized connection, switch
the server OFF in the pane — Activity shows "‹client› was disconnected when the MCP server was turned off".

**The Activity stamps (record-only, the orchestrator's "one cheap look").** A ONE-LINE FACT, not this unit's code:
`MCPActivityRowView` (`App/Variorum/Variorum/Features/MCP/MCPPane.swift` ~:915, 13n-b U3 `763e3f91a`) builds its stamp
as `Text(MCPPane.relative(line.at))` — `RelativeDateTimeFormatter` against `Date()` at the moment the body renders, with
no time dependency. SwiftUI re-renders the row only when the door's snapshot changes, and Settings' scene keeps its view
across a closed-and-reopened window, so "39 seconds ago" stays until the next activity row lands. Waiting's row already
ticks (`MCPPane.swift` ~:528 and ~:562 wrap the same call in `TimelineView(.periodic(from: .now, by: 30))`); the fix is
that wrapper on this row (and on the two other untimed callers, the connection request's first-seen ~:416 and the
client's last-seen ~:604). **The list itself does live-refresh:** `MCPDoor.read` reads `mcp_activity`, so GRDB re-emits
the snapshot on every new row; the round's "no new row" was the stop-road gap above, not a refresh failure. A Low
facelet ticket (Improvement · Confirmed · MCP) or a ladder note; not fixed here.

## U5 ADJUDICATION (the orchestrator, 2026-10-18 — after spot-verification)

- **Verified:** tip clean and pushed; the fold `460d39785` is a true merge of main `d8bb24488` (the one shared file
  `Operations+Tag.swift` auto-merged; `OpsRefusalTable.swift` untouched by this branch — the overlap question is
  CLOSED: no overlap); both Mac products built post-fold; per-piece commits, no trailers; the record complete; the
  one headless red is VX-353's known flake (green alone), again.
- **P-VX392-5 RULED AND APPLIED (the orchestrator's own small fix, `b570feb17`):** R-VX348-5's letter — "the
  instructions point at it" — wins over the brief's caution: the grants clause now reads "…a note, a book or a wing
  (list_wings lists yours)…", 2,994 of 3,000; the tool-names truth pin gains `list_wings` as a justified edit;
  `MCPAdviceServerTests` 14/14 and `MCPListWingsServerTests` 8/8 green after.
- **The two hollow halves stand as recorded** (the hallucination guard working as designed): a granted empty BOOK
  already listed; a NON-empty wing already read and wrote at every rung — her "can't see it or write in it" was the
  empty-wing case, now closed by `list_wings`.
- **P-VX393-1's consequence is FLAGGED for her** (the merge bundle, prominently): answering an ask "until it
  disconnects" on a place holding an "always" grant REPLACES it in full — nothing remains after the disconnect. The
  literal reading of her "upgrade in place"; she may prefer replace-never-downgrades.
- **VX-394 → "Needs Lillian":** the drop line shipped and the mechanism is traced (Castle's re-lock on her-use-only
  idle stops the server — matching every fact in the report; App Nap, timeouts, the path ruled out), but whether a
  connected AI's work counts as "use" for Castle's lock is a product call that is HERS alone: (a) as built — only
  her use holds the library open; (b) a client's calls count; (c) a Castle setting, off by default. No keep-alive
  built. Her confirmation that the night's library was in Castle is also owed.
- **Next:** U5's batch + live round READY once the fixed product's incremental rebuild (the adjudication edit)
  lands; U1's two leftovers (the VX-339 banner walk, the VX-357 wire check) ride the same window. U2 spawns after
  the rebuild so the tree stays still beneath it.

## U2 UNIT RECORD (VX-347 — ⌘S always commits; only ⎋ doesn't)

*Implementer: `opus-implementer` at xhigh, fresh session, 2026-10-18. Read in its own context before any code: this plan
(the VX-347 member section with her ruling, the Environment traps, the kickoff sitting, her overnight mandate, the U1/U5
records), `notes/SessionResiliencyProtocol.md`, `notes/plans/phase-13u3-faces.md`'s UNIT D brief + record + the
adjudications after it, QUESTIONS #121, CLAUDE.md + its canon, the ticket body. Lane: SwiftUI chrome (the shared field
in `Core/Views`) + the hosts' commit doors and `EditorCommands` routing; no `Sync/`, custody, Keychain, `Protection/`,
synced schema or TK2-seam line.*

**NOT DONE BY THIS UNIT (first line, by the brief's rule):** no `xcodebuild test` and no walk (the brief: the stage is the
orchestrator's) — every pin is written and compiled (`build-for-testing` green), and both legs are PREBUILT (`u2-fixed`,
`u2-red` — paths and commands at the end of this record), their RUN PENDING the batch; the walk (both voices, every
host) is PENDING the orchestrator's window — what it must show per host is listed below. "Typing on" is built on the
reading P-VX347-1 states (the field keeps the keyboard, as built); the other reading is a redesign recorded for her, not
built.

### LIVE STATUS

- **The trace + the design:** DONE (below).
- **The fix at the shared seam + the hosts:** DONE (`acbe5e5cb`; the classifier narrowed in `36c715ac2`).
- **The pins (the flipped `cancellingTheFieldFilesNothingAtAll` + the new leave-ways):** DONE (`36c715ac2`) — compiled;
  their run PENDING the batch (red leg first).
- **The prebuilt Mac products (u2-fixed / u2-red):** IN-PROGRESS (next commit).
- **No behavioural revert is in flight** (the red product is built from a SCRATCH checkout — this worktree is never
  reverted; announced in the products section before it starts).
- **Machinery note (honesty):** while this unit worked, the U5 fix leg's implementer was live in the SAME checkout
  (`Sources/VariorumMCP/` + its tests — disjoint from every U2 file; it committed `0ebf5c926` / `04d849d8d` and built its
  product from a clean checkout "U2's uncommitted work excluded"). Every U2 commit was staged path-limited; no U2 commit
  carries a U5 line and no U5 file was touched. Both U2 products are built from clean checkouts for the same reason.

### The trace (inputs → wrong state)

Her report: *"command S should always commit your take even without an extra keystroke to enter (but if you click escape,
then that can deliberately not save. the keyboard shortcut is lying right now since it's really command S enter)."*

1. ⌘S (`EditorCommands`' `.commitTake` → `ShellActions.commitTake` → `router.dispatch(.commit)` → the mounted surface's
   handler) reaches each model's DOOR — `EditorViewModel.commitCaretVariant` → `askSavepointName`,
   `TakesViewModel`/`CanvasViewModel`/`CompareViewModel.askSavepointName` — which only sets `savepointAsk`. Nothing is
   written at the press.
2. Every host presents that ask through ONE shared modifier, `savepointNameAsk` (`Core/Views/SavepointNameField.swift`):
   `popover(item:)` over `SavepointNameField`. Pre-fix it wired exactly ONE road to the host's filer — the field's
   `onSubmit` (⏎). ⎋ (`onExitCommand`) set the binding nil; a click away (AppKit's transient dismissal) and the host or
   window going ended at the same binding going nil; and "a dismissal that is not a filing is a cancel, by construction —
   the binding goes nil and nothing else happens" (the file's own doc, #121(b)). So the commit landed ONLY on ⏎: ⌘S was
   really ⌘S ⏎ — the "lying" shortcut.
3. A second defect the new rule would have exposed (found reading the filers, fixed with the rule): every filer re-read
   the CARET/RING at filing time (`commitCaret` → `caretVariantID`; `commitFocusedTake` → `focusedPane`/`livePane`), not
   the take ⌘S asked about. Under ⏎-only that was harmless (the field holds the keyboard, nothing moves); under the new
   rule a click away INTO ANOTHER BLOCK is a way of leaving, and that click moves the caret before the filing runs — so
   it would have committed the wrong take. Pinned (`aClickIntoAnotherBlockCommitsTheTakeAskedAbout`,
   `VX347AskedTakeFilingTests`).
4. A measured fact the fix must respect (VX-179's R1-2, `notes/plans/fixes/vx-179-comment-polish.md`): SwiftUI never
   tears a dismissed popover's content down, so `.onDisappear` on popover CONTENT never fires — the popover's own
   `NSPopover.willCloseNotification` is the one moment every dismissal shares.

### The field's home — ONE shared component (no per-host inline field)

`Core/Views/SavepointNameField.swift` — `SavepointNameAsk` (the value), `SavepointNameField` (the view),
`savepointNameAsk` (the modifier every host composes). The book's editing modes present it from `EditorView` (the
`.inSidebarBox` placement hangs it on the prose; the sidebar note box's `commit ⌘S` calls the live editor's
`commitCaretVariant`) — **nothing inline in `BookView` / `BookIndexView` / `SpreadBookView`, so no VX-382 residue and no
rebase owed by either run.**

### The fix (at the one seam; the hosts only file the ask they were given)

- **The rule — `SavepointNameLeave`** (pure): `.returnKey` · `.escape` · `.away` (every other way). `files(kind)`: at the
  commit door every leave but ⎋ files; at the RENAME door ⏎ alone renames (P-VX347-3). `closing(...)`: a popover closing
  with no key of the field's own is ⎋ ONLY when the event AppKit is dispatching is a fresh (< 1 s) ⎋ or ⌘. addressed to
  the field's popover window or the window it hangs from — so a popover that cancels itself on ⎋ can never file, and a
  stale event can never keep a commit from filing.
- **The box — `SavepointNameLeaving`** (one per host, the modifier's `@State`): every road reports a leave; the FIRST
  report decides, every later one for the same field is a no-op (⏎ then the popover's own close files once; ⎋ then the
  close files nothing). A settled field stays settled until the host's ask moves, so a late closing can never re-open it;
  a fresh ⌘S is a fresh field. The name is what was typed (the field's binding writes it synchronously), through the ONE
  `SavepointName` rule (spaces = no name).
- **The roads** — the field's ⏎ (`onSubmit`) and ⎋ (`onExitCommand`, settled BEFORE the popover closes); the popover's
  own closing (`SavepointPopoverClosingWatcher`, on `CommentPanelHostWatcher.isHost` — VX-179's identity rule); the
  host's ask moving (`.onChange` — always `.away`); the host going (`.onDisappear` on the HOST, which does fire).
- **The filers** — each model gains `fileSavepoint(_ ask:, named:)`, committing `ask.targetID` (Compare flushes
  `ask.context`'s coordinator — the pane's own post rides the ask); `fileSavepoint(named:)` stays as "⏎ on the pending
  ask" (the shipped pins' road); `commitCaret`/`commitFocusedTake` keep their shipped behaviour for their callers. The
  flush-then-commit ordering, the refusal roads and the receipts are unchanged.
- **⌘S again** while the field is up lets go of the ask — which LEAVES the field, so it files (P-VX347-2); no second
  field opens. (A click on a bar's `commit ⌘S` button with the field up is a click away first — it files — and then the
  button opens a fresh field: recorded consequence.)
- **The words** (PROVISIONAL, P-VX347-4): the field's hint "⏎ or clicking away commits it · ⎋ doesn't. An empty name is
  fine."; the two `commit ⌘S` doors' helps; the helper's commit entry and ⌘S row. The vocabulary is "commit"
  (R-13s-31).
- **Not changed:** the commit op (append always — her ⌘S never dedupes, P-VX168-U2-1's note), the door's seal refusal,
  the rename op, the tutorial lesson and the cheat sheet (still true — "press ⏎ to save it unnamed"), every `Sync/`,
  custody, schema and TK2-seam line. Zero `Shared/` lines: nothing mobile-visible (the phone's commit files at once).

### THE SWEEP TABLE — every host × every leave-way

All seven hosts compose the ONE presenter, so the mechanism column is the same for every row; what differs per host is
the filer (which take, which coordinator) and how "the window" closes.

| host (presenter site · filer) | ⏎ | ⎋ | click away | type on | close window |
|---|---|---|---|---|---|
| **Write** (`CommitBar` · `EditorViewModel.fileSavepoint(ask)`) | FIXED — files once (`onSubmit`; the closing after it is the same leave) | SAFE — `onExitCommand` settles ⎋ first; backstop: the closing classified ⎋ | FIXED — the transient close → `willClose` → files; files `ask.targetID` though the click moved the caret | FIXED via the click — the field keeps the keyboard (P-VX347-1), so going back to type is a click into the prose: the commit files on that click, before her first keystroke lands (the filing Task runs on the main queue ahead of the next event; `flushNow` snapshots synchronously) | FIXED — the parent window's close closes the popover (`willClose`) and/or the host leaves (`.onDisappear`) |
| **The book's editing modes** (`EditorView` `.inSidebarBox` · the same `EditorViewModel`) | FIXED (same) | SAFE (same) | FIXED (same) | FIXED (same) | FIXED (same; ⇧⌘W / a note switch = the host going) |
| **Takes / Lenses** (`TakesBottomBar` · `TakesViewModel.fileSavepoint(ask)`) | FIXED | SAFE | FIXED — files the asked take though the click moved the ring | FIXED via the click | FIXED (a mode switch = the host going) |
| **Write's take panel** (`WriteTakesPanel` header · its `TakesViewModel`) | FIXED | SAFE | FIXED | FIXED via the click | FIXED — the panel (a sheet) closing (⌘⇧T, its close) = the host going |
| **Canvas** (Debug; the strip's overlay · `CanvasViewModel.fileSavepoint(ask)`) | FIXED | SAFE | FIXED — files the asked card's take though the click moved the live pane | FIXED via the click | FIXED |
| **Compare** (the header's overlay · `CompareViewModel.fileSavepoint(ask)`) | FIXED | SAFE | FIXED — files the asked pane's take, flushed through ITS post's coordinator (`ask.context`) | FIXED via the click | FIXED |
| **Block History rename** (the row's Name/Rename button · `BlockHistoryModel.rename`) | unchanged — renames | unchanged — leaves it as it was | SAFE (by rule) — a rename dismissed keeps the name as it was (P-VX347-3) | n/a (no take behind it) | SAFE (by rule) — as before |

Beyond her five: **⌘S again** — FIXED on all four models (files; no second field — P-VX347-2); **the app switching
away / ⌘W** — the popover's closing, classified away → files; **⌘Q with the field up** — NOT on her list and NOT built
(P-VX347-5): the quit road does not wait for the filing's Task; the take's leaving savepoint (`closeAutoCommit`, quiet)
still insures dirty text.

### The pins (compiled; the RUN is PENDING the batch)

**Red on old by BEHAVIOUR — they use only pre-fix APIs, so the red product is the TRUE pre-fix tree for these files:**
- `SavepointCommitDoorTests.onlyEscapeLeavesTheFieldWithoutACommit` — **THE FLIPPED PIN** (was
  `cancellingTheFieldFilesNothingAtAll`; a justified edit naming VX-347): Write's real bar mounted; the field left as a
  click away leaves it → ONE unnamed manual commit; a second ⌘S left by ⎋ → still one. Expected RED (0 commits).
- `VX347CommitLeavesMountTests` (the product's presenter — `CommitBar` over the real `EditorViewModel`, VX-179's offscreen
  popover rig): `aClickAwayFilesTheCommitUnnamed` · `aClickAwayFilesTheNameSheTyped` · `theHostGoingFilesTheCommit` ·
  `theWindowClosingFilesTheCommit` · `commandSAgainFilesTheOpenField` · `aClickIntoAnotherBlockCommitsTheTakeAskedAbout` ·
  `typingOnAfterTheFieldLeavesKeepsTheCommitAsItWas` · `aLockedTakeStillRefusesWhenTheFieldIsLeft` ·
  `aSealThatLandsWhileTheFieldIsUpStillRefuses` — each expected RED; GUARDS (green on both sides by design):
  `escapeAloneFilesNothing` · `returnFilesExactlyOnce` · `anUnchangedTakeCommittedTwiceIsTwoCommits` (the dedupe
  unchanged: append always).
- Copy: `SavepointNameAskTests.theFieldTeachesItsTwoKeys` and `SavepointNameCopyTests.theHelperTeachesTheNameAndTheSkipKey`
  gain the new contract's words (justified edits) — expected RED on the shipped copy.

**The new seam's own pins** (`VX347SavepointLeaveRuleTests` — new API; NOT in the red product, which cannot compile
them): `VX347LeaveRuleTests` (the leave table · the ⎋ classifier · no event = away · the hint) · `VX347LeavingBoxTests`
(first report decides · ⎋ then the closing files nothing · a click away files what was typed · a fresh ⌘S is a fresh
field · the model letting go files · a field the box never saw open still files · the host going · an ask replaced
leaves the first · the rename door renames on ⏎ only) · `VX347AskedTakeFilingTests` (Write · Takes · Canvas · Compare
each file `ask.targetID` after the caret/ring/pane moved; ⌘S again lets go on all four models).

**Shipped pins riding unmodified** on the touched roads: `SavepointCommitDoorTests`' other four, `SavepointTakesDoorTests`,
`SavepointSealedDoorTests` (all five doors refuse a seal before a field), `SavepointRenameDoorTests`,
`WriteTakesPanelRoutedTests`, `CommandRoutingTests`' routed ⌘S, `CompareBoardTests`/`CanvasAndPoolTests`'
`commitFocusedTake` pins, `EditorSessionTests`' flush-then-commit pins, `TutorialWalkTests`' ⌘S arms.

### PROVISIONAL (for the merge's QUESTIONS bundle)

- **P-VX347-1 — "typing on".** Built: the field keeps the keyboard on appear (as UNIT D built it; her "the field
  stays"), so typing after ⌘S types the NAME; going back to the take to type on is a click into it — a way of leaving,
  which files the commit before her first keystroke lands. Alternative (b), NOT built: the field opens WITHOUT the
  keyboard — typing on in the take files the commit unnamed and the keystroke lands in the take; a click into the field
  names it; ⎋ while it shows takes it back. (b) needs a key intercept over every host while the field shows — Write's
  included, whose text view is the TK2 editor seam (out of this lane, Fable-reviewed) — and a first-keystroke snapshot
  rule; it is her call whether (b) is what she meant.
- **P-VX347-2 — ⌘S again** while the field is up leaves it (files, named with what was typed) and opens no second
  field. Alternatives: (b) it files the first AND opens a second field (two commits); (c) nothing (pre-fix).
- **P-VX347-3 — the rename door keeps ⏎-only** (a dismissed rename keeps the name as it was — its shipped "⎋ leaves it as
  it was"). Her ruling names ⌘S. Alternative: (b) one rule for the one field — any leave but ⎋ renames too.
- **P-VX347-4 — the words** (the hint, the two doors' helps, the helper's entry and ⌘S row); the tutorial lesson and the
  cheat sheet left as they were (still true). Her copy pass.
- **P-VX347-5 — ⌘Q with the field up** files nothing (not on her list; the quit road does not wait for the filing). The
  quiet leaving savepoint still insures dirty text. Alternative: a step on the termination road.

### What the walk must show (the orchestrator's window — both voices, the dev store)

Per host, each a capture: **Write** (the bar) — ⌘S, click into the prose: the receipt "Committed." and Block History +1;
⌘S, type "named", click away: Block History leads with "named"; ⌘S then ⎋: no receipt, no new row; ⌘S ⌘S: one new row,
no second field. **A book's editing mode** (Index edit or the Book page's inline editor) — ⌘S on a note's prose, click
another note: the commit is on the first note's take. **Takes** — ⌘S on take 1, click take 2: the commit is take 1's.
**Lenses** — the same bar. **Write's take panel** — ⌘S in the panel, then ⌘⇧T: the commit lands. **Compare** — ⌘S in a
peer pane, click the anchor column: the commit is the peer's. **Canvas (Debug)** — ⌘S on a card, click another card: the
first card's. **Close window** — ⌘S, close the window by its button: reopened, Block History +1. **⇧⌘W** with the field
up: +1. **Block History rename** — Rename, type, click away: the name unchanged. **The hint** — in both voices at the
field's width, three lines at most, no truncation. **⎋ on every host** — nothing filed.

### The Mac products (PREBUILT — the batch window runs `test-without-building` only)

**ANNOUNCED BEFORE IT STARTS (addendum 2):** both legs build from SCRATCH `git worktree add --detach` checkouts of the
U2 tip in the session scratchpad — this worktree is never reverted, so it is never mid-revert. The RED checkout restores
the PRE-FIX content of U2's eleven source files (`git checkout acbe5e5cb^ -- <file>` for `SavepointNameField.swift`,
`EditorViewModel.swift`, `TakesViewModel.swift`, `CanvasViewModel.swift`, `CompareBoardView.swift`, `CommitBar.swift`,
`EditorView.swift`, `TakesBottomBar.swift`, `WriteTakesPanel.swift`, `CanvasView.swift`, `HelperView.swift`) and removes
`VX347SavepointLeaveRuleTests.swift` (new API — the red tree cannot compile it; the project's folders are synchronized,
so the file's absence is its absence from the build). Every other test file is the U2 tip's. PENDING: the build logs'
proof that the reverted files compiled, and the two paths.

### For the orchestrator's closeout (not U2's to apply)

- **QUESTIONS #121(b) is superseded** by her VX-347 ruling (the closeout marks it); #121(a)'s "⌘S opens a field" stands.
- **AppSpec §12** may want one contract line: ⌘S's optional name field — every way of leaving it but ⎋ files the commit,
  named or unnamed (VX-347), the rename door unchanged.
- **The PROVISIONALs:** P-VX347-1…5 (P-VX347-1 the one with a redesign behind it — worth her eye first).
- **No VX-382 overlap** (the field is not inline in the book views).

## THE U5 BATCH + LIVE ROUND (the orchestrator, 2026-10-18 ~05:47–06:20, claim `vx-348-u5-batch`)

- **RED leg** (u5-red, test-without-building): exactly as predicted — `MCPConnectionEndDoorTests` 3 of 3 red,
  `listWingsSpeaksItsOwnWords` red with the rest of `MCPWingFacesTests` green (13 tests / 2 suites).
- **FIXED leg** (u5-fixed): 242 tests / 31 suites, ONE red — `theDoorsTwoStopRoadsSayTheirReasonsOnce`
  (`ends == []` on the serverOff arm; deterministic alone; the suite's other two pins green alone).
- **THE LIVE ROUND (the dev store, Debug from the u5-fixed product, a REAL Claude Code client over the real shim,
  scratch config, never her user scope; captures in `notes/plans/vx348-screens/u5/`, gitignored):**
  - **VX-392's done-when PROVEN:** wing "U5 empty wing" minted empty through her doors; granted to `claude-code` at
    edit·always through THE one grant sheet (WHERE = A wing); a fresh `claude -p` found it in ONE `list_wings` call
    (the only wing listed — the client's BOOK grant correctly listed no wing) and created "first book" in it
    unaided. Activity spoke "claude-code listed its shared wings" and "claude-code made the book "first book"" —
    the pinned wording, live. The VX-258 zero-click tab-key re-bind line observed live too.
  - **The batch red is a REAL GAP, live-confirmed:** with a live initialized connection held open, her switch OFF
    killed the shim (process gone) but wrote NO end line — the row set unchanged across tab flips, a reopened
    window and a brand-new Settings window (a new row would have topped the list; none did). The clientClosed road
    DOES write (the exited `claude -p`'s "claude-code disconnected" landed live). So the STOP roads (her switch;
    presumably the lock road's stop half) lose their reason — the U5 implementer's fix leg, the red pin the proof.
  - **A second small observation, recorded not ruled:** the Activity tab's relative stamps never recompute ("39
    seconds ago" frozen across minutes and across a NEW window) — a candidate facelet finding for the ladder or a
    ticket at closeout.
  - **VX-357's wire half PROVEN (U1's owed item):** a REAL U+0000 sent through the real shim's `create_note`
    (the model-driven leg double-escaped — the digest exposed it; the deterministic frame followed):
    `null_characters_removed: 1` in the answer and `sha256 = 31c2400e…` = sha256("beforeafter"), the STORED
    stripped text. The fingerprint is true.
  - **Fixture residue, per the posture terms (content may grow):** the wing "U5 empty wing" (book "first book",
    notes "u5 null check" ×2), `claude-code`'s wing grant (edit·always). The ⌥⌘A mis-fire's once note grant was
    REVOKED in-window. Server back ON; Debug app QUIT by bundle id; pgrep empty at RELEASE.
  - **Deferred to U3/U4's walk window:** VX-393's live double-share check (pin-proven already), the Terminal-voice
    captures of the new faces, and the VX-339 banner walk.

## U5 FIX-LEG ADJUDICATION (the orchestrator, 2026-10-18)

- **Verified and ACCEPTED:** the trace is concrete (the door drops its host at `stopServer`; the session task's weak
  self skipped `ended()`, so stop-road lines were never written — and the headless pins passed precisely because the
  harness held its host strongly: a textbook harness-realism gap); the fix is structural (the session writes its own
  end line, host-independent); the new pin `aStopThatLetsGoOfItsHostStillSaysEachConnectionsEnd` red-on-old by log,
  MCP target 383/71 green; the u5-fix product prebuilt from a clean checkout of `0ebf5c926` with U2's uncommitted
  work excluded. **The door pin's run (expected all green now) rides the next stage window** (folded into U2's
  batch REQUEST) and the optional live re-check rides U3/U4's walk window.
- **The two surfaced items are tickets, triaged at mint, neither joins the run:** the stop road's skipped
  `endMCPConnectionGrants` (no exposure window — the sweep runs first) → **VX-400** (Bug, Confirmed, MCP, Low); the
  Activity rows' frozen relative stamps (no TimelineView; the LIST refreshes fine — the live round's "stale list"
  caveat is resolved by this trace, strengthening the gap's confirmation) → **VX-401** (Improvement, Confirmed,
  MCP, Low).
