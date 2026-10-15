# VX-336 handoff — what an AI can do in your library now: add paragraphs, duplicate for Compare, check its own work, and its guide (2026-10-15)

**Run:** VX-336 "Run: MCP wire tools & AI docs" · PR #166, merged to `main` as a merge commit («sha» — the merge
commit's hash, filled after the merge) · the record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` (your rulings,
the orchestrator's provisional rulings, every unit record, the stage windows, the review) · built 2026-10-14/15 on the
Pro under your kickoff answers and your overnight word: *"I am going to sleep, rule provisionally overnight in my
absence and leave me a handoff in the morning. you or 283 can merge last, whoever does should have a release build
ready, write notes on what was updated (I don't have to review those notes, it's fine), and push a release to the
website so I can try the new things out tomorrow morning."*

## Your checklist

1. **Try the new release: 0.9.7 («build N» — filled after the release is cut).** It is on the website and in
   `/Applications`, cut by this run (VX-283 hadn't reached its closeout, so this run merged last). What to try first,
   with Claude Code connected to a library you've shared with it:
   - Ask it to add a paragraph at the end of a note it can write in. Then ask it to add one in the middle: with Write
     new it can't, so it asks you for Edit, and the ask waits under Settings ▸ MCP ▸ Waiting.
   - Ask it to duplicate a note and rewrite the copy, then to show you the two side by side. Compare (⌘5) opens with the
     copy's paragraphs lined up against the original's.
   - Share the sherlock book, open one of its stories, and look at the book panel: every chapter row now wears the small
     shared icon.
   - Ask it to read a long note and check its work against what it wrote. Settings ▸ MCP ▸ Activity then shows lines
     like "claude-code read “…” (6 times)".
   - Takes it suggests now read "claude-code · english" (no "suggested"). Takes made before keep their old labels.
2. **Get the refreshed field guide chapter, if you want it.** Your library keeps the guide it already has. Help ▸
   Restore Tutorial… asks first, then moves the old guide (the book "the field guide", every note tagged exactly
   "tutorial", including any of yours with that tag, and the "tutorial scraps" pool) to the Trash and puts a fresh guide
   on your Bookcase, on the Welcome shelf. Anything you changed in the old guide stays in the Trash for 30 days. The
   chapter is "AI & the MCP door".
3. **The AI guide page is live:** https://stargazing.tech/variorum/mcp. It went up last night at your word, so the
   release could carry the link the AI is given. Its words are stand-in copy, marked PLACEHOLDER for yours (your site
   repo's DECISIONS #86 and PLAN.md's content-owed list). Rewrite it whenever you like; keep the path.
4. **Ratify or reverse the provisional calls: QUESTIONS #227.** Each was built as stated there, with a line to reverse
   it. The ones most worth your eye:
   - Where an AI's duplicate lands: in no book, in the note's own wing's Pool, as your Duplicate as Version does, so the
     AI needs Write new on the whole wing (an AI whose Write new reaches only one book can't duplicate).
   - "At the end" for added paragraphs: with Write new, only by naming no block at all; naming any block, even the last
     one, needs Edit.
   - The nine new refusal sentences you may now see on the Mac and the phone, where a raw "Refused: …" dump used to
     show (the list is in #227 and below).
   - How long a page of a long note is: it ends before the AI's whole answer passes 32,000 characters.
   - And: a note shared one ask at a time (a daily Journal entry, anything Private) can't be duplicated by an AI.
5. **Two pre-launch calls are yours:**
   - **VX-363** (fixed in this run): an AI could learn the name of a book it can't read by importing a book with the same
     name. Should it carry Pre-launch?
   - **VX-357** (not fixed): text holding the invisible character U+0000 is stored cut off at it, on every door, yours
     included, and an AI's new fingerprint then vouches for the whole text. Pre-launch or not?
6. **Your wording pass, VX-234, has every word this run added or changed** (the list below, each where it shows).
7. **The tickets this run filed** are listed below by priority, each labeled; none has an assignee.

## What to know

- **The night ran on provisional calls.** You asked for that, and nothing on the never-without-you list was touched
  (no accounts, nothing of yours deleted, no history rewritten, no synced schema change). Two of the orchestrator's own
  calls joined work to the run: U9 fixed two problems the first organization round met (a new note's answer said it had
  no tags when its book had tagged it; one refusal arrived as a raw Swift dump), and it fixed VX-363 above. A third call
  (to ship without the guide link) was overtaken by your word to publish the page ourselves.
- **Nothing to do for the AI clients you already use.** Every grant and setup stands. The tools simply grew.
- **The release notes for 0.9.7 were written without your review**, as you said was fine for tonight. This run cut the
  release. Its notes are this run's section, drafted in the record's CLOSEOUT BRIEF ("THE 0.9.7 NOTES — VX-336's
  section"); the release puts them in the app's What's New as `ReleaseNotes-0.9.7.md`.
- **Ten small commits appear twice in `main`'s history.** While merging `main` into this branch, one git step replayed
  ten of `main`'s commits, all notes and process files (six board snapshots, two in-flight rows, the closeout-ritual
  rule and the ticket-labeling rule), onto the branch under new names, so after this merge `main` holds each of them
  twice, with identical changes. Nothing was rewritten
  and no file differs because of it. Removing the copies would need a force-push, which is yours alone to decide; none
  is proposed.

## The release (0.9.7)

- **Cut by this run,** after the merge, because VX-283 hadn't reached its closeout: the version bump,
  `Tools/Release/release.sh`, the website, and the `/Applications` refresh under the stage coordinator's rule card.
- **What it carries:** this run's work (below) on top of 0.9.6. Its notes are the record's "THE 0.9.7 NOTES" section,
  one line per bullet.
- **Its facts,** filled after the release: the build «N» · the refresh's A1 copy of your real store «path» · the
  replaced app in your Trash «name».

## What shipped

- **VX-267 — labels.** A take an AI suggests is labeled with its name, then its own label if it gave one:
  "claude-code · english". Work you authorized it to write keeps clean labels, as you ruled.
- **VX-253 — saving a lens by label.** An AI can say "the english takes" instead of naming every take. If two takes on
  one paragraph both fit, it stops and asks which, rather than guessing; it never picks up another AI's takes.
- **VX-252 — what a new note answers.** A note an AI makes answers with the ids of everything it made, so it never needs
  to read the note back just to learn them, and it can file the note under a chapter in the same step.
- **VX-255 — adding paragraphs.** With Write new, an AI adds paragraphs at the end of a note; with Edit, anywhere. One
  ⌥⌘Z takes the whole addition back.
- **VX-311 and VX-298 — duplicating and Compare.** An AI can duplicate a note the way your Duplicate as Version does, so
  Compare lines its rewrite up with your original row by row, and it can open Compare to show you two to four notes side
  by side when you ask (only while Variorum is in front, never on its own). When an AI links two notes as versions, the
  confirmation's Open › opens them in Compare.
- **VX-254, VX-256 and VX-261 — an AI checking its own work.** Writes answer with a fingerprint of exactly what was
  stored, long notes are read in pages small enough for the AI to take in whole, and an AI can look back over its own
  recent acts to see whether a call went through after a dropped connection.
- **VX-361, VX-362 and VX-363 — clearer, safer answers** (all three filed by this run and fixed in it: VX-363 High,
  VX-361 and VX-362 Medium). A note made in a book that tags its notes says so; tagging a note twice is simply fine;
  every refusal the door knows of is in plain words; and importing a book can no longer reveal the name of a book the
  AI can't read.
- **VX-330 — the book panel.** A chapter that is one note (every chapter of sherlock) wears that note's shared icon and
  its waiting mark.
- **VX-342 — the undo warning** no longer shouts "BEFORE", on the Mac or the phone.
- **VX-197 — the AI's docs.** The instructions every connected AI receives were rewritten (now up to 3,000 characters,
  ending with the guide page's link), twelve tool descriptions were corrected, and the field guide's AI chapter was
  re-voiced and taught everything above.

## How it was checked

- **Every fix has a test that failed on the old code and passes now,** and each was failed again by reverting the fix.
- **Five stage windows on the dev store,** each restored byte for byte afterwards: Mac test batches of 251, 790, 176,
  432 and 771 tests (the only reds the two standing ones, VX-115 and VX-167), the phone suites twice (18 and 120 tests),
  walks in both voices, and real Claude Code 2.1.300 rounds for every new tool — each answer read from the wire's own
  bytes, never from the AI's wording.
- **The page size was measured, not guessed.** The first round found a full page ran past Claude Code's limit and was
  saved to a file; the bound was moved to the whole answer, and all three re-probes then arrived whole.
- **The review:** round 1, a Fable review at xhigh (your cast word): one major (the last unit's window hadn't run yet —
  it ran), two minor (the spec's numbers owed — now written; a stale status line), two nits; no code needed fixing.
  Round 2, a fresh Fable review at xhigh: one minor and three nits, so no third round. The minor: a Compare board an AI
  opened could, much later, flip your own "related blocks only" toggle if one of the notes it named had been deleted
  before the board drew it. Fixed, with four tests that failed on the old code and pass now, and the orchestrator
  checked the fix line by line. The nits: one test comment, one line in this handoff's wording list, and one wording
  note (also on that list).
- **The closeout window, on the code exactly as it merges** (`main` merged in; the dev store restored byte for byte
  after): the whole Mac test target ran once, 4,714 tests in 777 suites. Four reds, none new: the three that stand on
  `main` already (VX-115, the Book Settings door; VX-245/VX-283's six line-limit sites outside the MCP pane; VX-167, the
  redo warning under parallel load) and one find-bar test that the machine's load tripped and that passed when re-run
  alone. The phone's 15 suites passed (120 tests). Headless: MCP 349 tests / 67 suites (one known issue, VX-357) · core
  2,872 / 333 · workbook 40 / 6.

## Your wording pass (VX-234): every word this run added or changed
- Two small wire-doc notes from the review (no behaviour): `read_note`'s commit `length` counts Swift characters while its page budget counts UTF-16 units (the same word, two meanings); and on a paged read the note's `books` list rides every page while the other note-wide lists ride the first page only. A later description pass can say both.

In your app (the Mac unless said):
- **Take labels** on Takes cards, the take panel and Lenses: "‹client› · ‹label›", or "‹client›" alone (was
  "‹client› · suggested · ‹label›"). In Terminal a Takes card can cut it to "claude-code · e…" (VX-352).
- **Added paragraphs:** Activity "‹client› added blocks to “‹note›”" (and " (N times)") · refused "‹client› was refused
  adding blocks to “‹note›”" · the confirmation "‹client› added a block" / "‹client› added N blocks", with Open › at the
  first new one · Edit ▸ "Undo ‹client›'s blocks", and when it was already undone "Nothing to undo — ‹client›'s blocks
  was already undone or changed since."
- **Duplicates:** Activity "‹client› duplicated “‹note›”" (and " (N times)") · refused "‹client› was refused duplicating
  “‹note›”", or on the wing's side "…was refused duplicating a note in “‹wing›”" · the confirmation "‹client› duplicated
  “‹note›” · ⌥⌘Z undoes" (Open › opens the copy; "made N duplicates" for several) · Edit ▸ "Undo ‹client›'s duplicate"
  and "Undid: ‹client›'s duplicate".
- **Linking versions:** the confirmation can read "‹client› made a change · ⌥⌘Z undoes Open ›" when the full line would
  pass the bar's room — by design, worth your eye.
- **Recent acts:** Activity "‹client› checked its recent activity" (and " (N times)") · refused "‹client› was refused
  checking its recent activity". A long note read in pages shows as one line: "‹client› read “‹note›” (N times)".
- **The undo warning:** Mac "…undoing puts back the text as it was before the ‹label›, so that writing is set aside. It
  is committed first, so you can bring it back from the take's history (⌘S's list) at any time." · the phone "…as it was
  before the ‹label›, so that writing is set aside. It is saved first, so you can bring it back from the block's Block
  History at any time." (the phone's "saved" where the Mac says "committed" is VM-20).
- **Refusals, Mac and phone** (also what an AI hears): "That note is already in this book." · "This book is at its note
  limit." · "That comment is already back." · "A chapter needs a name." · "That note isn't there any more — it may have
  just been deleted." · "That isn't a book — a gathering shows the notes its rule matches and holds none of its own." ·
  "That's already a book — only a gathering binds into one." · "That tag isn't there any more — nothing changed." ·
  "That block is already in a note — nothing changed."
- **Sentences that now say less than is true** (not false, not changed): the grant sheet's Write new line at a note
  ("…it can also apply tags and save versions of it") doesn't mention adding paragraphs at its end; the Write new
  consent sentence ("make new notes…") names no duplicate, link or added paragraph.
- **The field guide's AI chapter:** lessons 1, 2, 3, 6 and 7 rewritten (4 and 5 unchanged). It calls the sha256 a
  "fingerprint", calls the book panel "the panel that shows a note's book", and lesson 3 grew to eight paragraphs.

What an AI hears (never shown in your app; listed so every changed sentence is in one place): the instructions (whole
in the record's U8a section, "THE INSTRUCTIONS AS BUILT"); twelve tool descriptions; and two refusals that use Mac-door
words to an AI ("…since you picked it", "…if it's sealed, unseal it.").

## Tickets this run filed and left open (by priority; each labeled; none has an assignee)

The three it filed and fixed (VX-361, VX-362, VX-363) are under "What shipped".

- **Medium:**
  - VX-357 — text holding U+0000 is stored cut off at it, on every door, and an AI's fingerprint then vouches for the
    whole text (Pre-launch is your call).
- **Low:**
  - VX-366 (Needs Lillian) — dividing, merging, saving a version and importing a whole book answer no fingerprint; it
    waits on your answer to P-VX254-1/2 in #227.
  - VX-367 (wording) — the guide's lesson 3 names the edit rung's remaining acts one by one.
  - VX-368 — an audit of what you can do at the keyboard that an AI still can't (moving a span to a new take, renaming
    a tag, extract, copying takes to both halves of a divide, word targets); Pre-launch is your call.
  - VX-369 — an error other than an operation's own refusal may still reach the AI as raw text.
  - VX-370 (exploration) — measure another AI client's answer limit against the 32,000-character page.
  - VX-364 — a book whose wing went missing by sync refuses its outflow tags.
  - VX-365 — adding a note to a book doesn't say the book tagged it.
  - VX-358 — an AI edit that only re-spells a text's Unicode counts as no change.
  - VX-355 — the Pool shows no confirmations (it has no bottom bar).
  - VX-356 — in Study, the open note's collapsed chapter row shows no open-note marker.
  - VX-354 — the book panel's book name and gatherings line wear no shared icon (Pre-launch is your call).
  - VX-353 (test-only) — a test that overruns its time limit under heavy load.
  - VX-352 — Terminal cuts an AI take's label on a Takes card.
  - VM-20 (the phone) — the phone's undo warning says "saved" where the Mac says "committed".
- **Not filed as new:** a note on VX-122 (an open Library didn't show two notes an AI made until re-entered).

## For the other runs

- **VX-283:** this run added one property and three lines to `CommandRouter.swift` (`pendingCompareLanding` and its
  clears, beside the lens landing's) and one word to `ShellActions.discardingUndoDetail`; both were told to it first.
  The shared refusal table gained nine sentences: a door of yours that refuses through `OpsRefusalCopy` now speaks them.
  It merges after this run, so it merges `main` in first.
- **VX-292 (the tutorial):** the field guide's AI chapter changed (lessons 1–3, 6, 7 in `TutorialSeeder`); whichever
  run lands second rebases onto the first.
- **The phone:** two shared changes reach it at its next build — the lowercase "before" and the nine refusal sentences
  (PL-56).

## Left on disk

- The dev store's A1 copies from the six windows, each restored from and verified the same — the stage coordinator's
  to prune: `scale-prestage-20261014T211517Z` (U5), `-20261015T000711Z` (U6), `-20261015T024700Z` (U7),
  `-20261015T051427Z` (U8), `-20261015T070459Z` (U9), `-20261015T082808Z` (the closeout), under
  `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/Backups/safety-copies/`.
  `castle-W1-20261013` there is yours, untouched.
- The refresh's A1 copy of your real store «path» and the replaced app in your Trash «name» (filled after the
  refresh).
- Nothing else: the run's test kits left the branch before the merge (they stay in its history), and its screenshots,
  logs and build folders are deleted after it.

**MOBILE PARITY:** PL-56 in `notes/MobileSoul.md` — the phone's undo warning says "before" in lowercase, and the shared
refusal table's nine sentences reach the phone's doors; nothing else is mobile-visible (the AI door is Mac-only).
(Separately, `notes/MobileSoul.md` has two older rows both numbered PL-53, VX-143's and VX-168's; left as they are.)

## For a fresh session

Everything lives in `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`: its CLOSEOUT RECORD names what landed where
(PHASE C lists every ledger and its commit). The door's contract is `notes/MCPSpec.md` (this run's block: "THE WIRE
TOOLS AND THE AI'S DOCS"); the bundle to ratify is QUESTIONS #227.
