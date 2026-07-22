# Phase 13b — author handoff (written 2026-07-22 at the phase closeout)

**Self-contained by design.** A fresh session can answer questions about
13b from this file plus `notes/plans/phase-13b-make-it-work.md`; nothing
here depends on the sessions that did the work (three of which are gone).

---

## YOUR CHECKLIST (in the order I'd do it)

- [ ] **1. Open the app and confirm it shows a window.** I refreshed
  `/Applications` from a green Release build and it launched, migrated
  v1_12, and left your store intact — but from *my* vantage it showed
  **zero windows** (menu bar alive, a "Variorum" entry in its Window
  menu, quit refused). I did **not** call that a defect: my screenshots
  didn't show your Terminal either, so what I was capturing was
  demonstrably not your screen. **If it opens normally for you, ignore
  this line.** If it genuinely opens windowless, that is a launch
  defect and it is the first thing the next session should fix — the
  previous build is recoverable by rebuilding from commit `826bf61`.
- [ ] **2. Sign in to sync — it has been signed out since 2026-07-20.**
  Found during the deploy, and **pre-existing, not caused by it**: there
  is no `io.lduarte.Variorum.auth` Keychain item (only the bridge's
  separate `…fragments-auth`), so the engine refuses rounds and leaves
  the outbox intact — by design. Your store is carrying **~1,216 queued
  rows, oldest stamped 2026-07-20T05:06Z**. **Nothing is lost**; it
  drains when you sign in. Sign-in still needs the consent page served
  on your LAN until the stargazing.tech page ships:
  `cd Spikes/AuthPairingSpike && python3 -m http.server 3000` (the
  standing 9c residual). *Your Fragments bridge was unaffected — it has
  its own session and was working today.*
- [x] **3. Re-seed the field guide — DONE 2026-07-22** (you authorized
  it after confirming the app opens). Ran Help ▸ Restore Tutorial… and
  pressed Replace via the app's own door; verified by the store: the old
  field guide (`423C671D…`) is tombstoned and a fresh one
  (`CEF73570…`, created just now) carries all 6 chapters, 21 memberships,
  22 tagged posts, and the scraps pool; zero journal-shaped rows (R57);
  your 49 containers / 3 readings untouched; `integrity_check` ok. A
  fresh backup was taken first (`variorum-backup-2026-07-22-230128.sqlite`,
  beside the earlier `…-203034`). The instance I launched to do it is
  still open on the fresh tutorial — quit it whenever.
- [ ] **4. When your Fable credits reset: `/architect-phase 13c`.**
  The plan is written and complete. Two obligations open that phase —
  re-reviewing the 76 lines of 13b gate fixes, and reviewing the applied
  canon deltas — both already written into it.
- [ ] **5. (Optional, no rush) Look at the "worth a look" list below.**
  Not a requirement — a list of what changed most, since you are the
  first eyes on several surfaces.

---

## What shipped, and whether it's trustworthy

**Stage 4 built everything you ruled at the kickoff sitting** (S4-1…S4-33
and both memo addenda), in seven batches:

- **The cut redesign** — cuts land between any two words and at
  newlines, with a word-edge floor and a gentle settle onto sentence
  ends; extract obeys the same one rule; in the ceremony a take's ✂
  parked at its end sends that take whole into the first block (mirror
  at the start), so no take is ever stuck without a legal placement.
- **The merge ceremony** — your canon ruling built: ＋ pairings mint one
  joined take each, carries ride whole, nothing cartesian, and
  divide-then-merge round-trips whole when you pair 1+1 and 2+2. Any fan
  on either side opens the sheet **pre-paired**, so ⏎ reproduces exactly
  what merge did before.
- **Compare rebuilt as "lenses across posts"** — fully editable cells,
  one live ring across posts, per-post drag reorder, up to four columns,
  the lineage-colour and follow-order toggles, and **N29 honesty** (two
  unrelated posts say "there is no relationship here" and sit plainly
  side by side). **Outline is gone as a tab** — folded in, its
  make-outline-post door now in Compare's header. **Modes are ⌘1–⌘6.**
- **Takes/editor QoL** — ⌥⌘N inserts a block below in both editors; the
  takes strip has one fixed height with in-strip scroll; the fan rail
  scrolls *and* pages with an honest counter; drag handles reveal on
  hover in Write (a setting, default on); **new posts open in Write**
  now (your S4-20 reversal), with per-post memory intact; the
  "newlines make blocks" switch; a direct comments button on the Takes
  bar plus a "+ //" chip in the margin; positional moves in the Blocks
  list; honest copy for move-to-pool and tag doors on scrap rows.
- **Canvas** — cards land in a spread grid instead of a pile, are
  editable and resizable, carry their block-order number, can be
  clicked in sequence to reorder the post, and fit-all opens a
  read-only overview. Your long-post question got a real answer: a
  never-opened canvas now realizes only what the viewport needs,
  independent of post size.
- **Books** — a progress bar, a Kindle-style paged view (page = a post,
  bottom scrub bar), **deleted books are restorable**, and posts can
  carry their own word target (migration v1_12, deployed).

**Trustworthiness, stated plainly.** Core **817/96** and Mac **652/123**
green, verified by my own runs, not by report. Every bug-class fix
carries a pin that fails on the pre-fix code, and **18 of those
revert-red procedures were executed and confirmed RED** at the gate.
Three ladder rounds ran. **What has *not* happened is visual
inspection** — see the list below.

---

## Worth a look (advisory, not owed)

You are first eyes on these because the visual review moved out of the
phase. Nothing here is known-broken; it is simply un-looked-at.

1. **Both ceremony sheets.** The take ceremony (fan a block, divide) —
   every checked take visible at once with its own draggable ✂. The
   merge ceremony (merge two blocks where either has takes) — the ＋
   pairing columns and the join preview.
2. **Compare**, and the fact that **Outline is no longer a tab**. If
   your muscle memory reaches for ⌘7, that is why.
3. **Canvas** — the spread grid, resizing, click-in-order, fit-all.
4. **The paged book view** (Book · Pages · Read) and the progress bar.
   These are also what 13c's uniform-page work will build on.
5. **The word-target door** — it lives on the word-count label in the
   editor's bottom bar. 4F itself flagged it as quiet; it may want a
   more obvious home.
6. **The margin "+ //" comment chip** — deliberately minimal (caret
   block only). The fuller hover grammar is recorded as a 13c candidate
   if you want it.

**Four PROVISIONALs I'd flag specifically** (each one guard line either
way, all recorded for your 13c kickoff): the per-post word target
**refuses under a sealed post**; merge-ceremony pairing is **1:1**
(multi-pairing deliberately unbuilt); the join choice is remembered
**per session** only; canvas card sizes persist **locally, not synced**.
And one behaviour a reviewer traced but nobody has *seen*: in Compare,
a peer post with **no** kinship to the anchor renders its content below
every aligned row — recorded as a PROVISIONAL in the 4C batch record,
yours to accept or change.

---

## What I did to your machine and your data

- **Backed up** your real store first:
  `variorum-backup-2026-07-22-203034.sqlite` (UTC name, in the store's
  own `Backups/`), `integrity_check` ok.
- **Deployed migration v1_12 to the mirror** under your standing
  pre-authorization — one additive nullable column plus the lockstep
  marker, run verbatim from `Server/supabase/07_phase13b_lockstep.sql`,
  mirror first per §12. Verified: marker **3 → 4** by the client's own
  RPC, column present and nullable, your 17 mirror container rows
  untouched.
- **Refreshed `/Applications`** from a green Release build (zero
  instances at build and copy; signature verified; RELEASE identity
  confirmed). Launching it applied v1_12 locally; your **49 live
  containers and 3 readings are unchanged**, integrity ok.
- **Did not touch** your tutorial content (verified identical before and
  after my attempt), your Fragments credentials, or anything you
  created. I terminated one app instance I had launched myself; the
  store passed `integrity_check` afterwards.

---

## Where the phase's own record lives

- **`notes/plans/phase-13b-make-it-work.md`** — the whole phase: the
  constitution, the ledger (every row dispositioned, no orphans), the
  batch records with their judgment calls, all three ladder rounds
  verbatim with dispositions, the gate execution record, and the Stage 4
  + phase-level closeouts.
- **`notes/plans/phase-13c-book-forms-and-conversions.md`** — the
  successor plan, ready to invoke.
- **The two 13c inputs 4F authored:**
  `phase-13c-uniform-page-view-brief.md`,
  `phase-13c-memo-smart-to-curated.md`.
- **Canon deltas applied this closeout:** AppSpec §7 (`container.word_target`),
  §9 (the cut rule + parking; `mergeCeremony`; `restoreReading`;
  `setPostWordTarget`), §14 (the Stage 4 delta), OverallModel §7 (merge
  pairing; the word-edge cut rule). **These are semantic, not
  bookkeeping** — 13c opens by reviewing them.

## Two things you should know about how this phase ran

**It survived two model cutovers mid-flight.** The Fable orchestrator
handed off at ~490k tokens after your Stage 4 kickoff sitting; the
successor ran 4A–4F and both early ladder rounds, then hit your Fable
limit mid-gate. The closeout, round 3, the gate fixes, the deploy, and
the 13c plan finished on Opus under CLAUDE.md's pre-agreed contingency.
**The 13c plan file's two commits make that seam auditable** — `224938b`
is the Fable draft verbatim, `7c28f59` is the Opus finish; the diff is
the handover.

**The gate failing was the system working.** Because your machine
auto-locked overnight, the Mac test runner couldn't run, and six batches
of app-side tests were written but never executed. When you unlocked and
they ran for the first time, three failed — and two were **real
defects**, including one on the single text surface every pane in the
app composes. That is exactly why the gate existed, and why the stage
could not close before it ran.
