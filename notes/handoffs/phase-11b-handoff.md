# Phase 11b — Author Handoff (2026-07-16)

Phase 11b (export/import + the reference panel — Stage B of Phase 11) is
CLOSED. **Phase 11 is now closed in full.** This document is
self-contained: a fresh session can answer your questions from it alone.

---

## Your checklist (in order)

1. **☐ Relaunch from `/Applications`.** The coordinator refreshes
   `/Applications/Variorum.app` to the post-ladder Release build if the
   app is quit; if it's running when they try, quit it and either ask
   them again or run the one-command refresh yourself:
   `xcodebuild -scheme Variorum -configuration Release build` then copy
   the product from DerivedData to `/Applications`. **The export doors
   only work in this new build** — the old install lacks the sandbox
   entitlement they need (the story is below).

2. **☐ The real-file walk (~10 minutes; this is the phase's TCC/sandbox
   verification — the pieces tests can't reach):**
   - Right-click a post in the sidebar → **Export ▸ Markdown…** — the
     save panel must APPEAR (this exact panel was impossible pre-fix)
     and the file must land where you point it. Open it: chosen takes
     only, blank lines where you stored them.
   - **File ▸ Export Library…** — pick a folder; expect one `.md` per
     post (dated/titled names), `Archived/` for archived posts,
     `Readings/` views. Everything you've written, out, in one gesture.
   - **Drag a real `.md` from Finder onto the sidebar** — a new post,
     titled from the filename, segmented like a paste. Try ⌥⌘Z once: the
     whole drop unwinds (even multi-file drops are ONE undo).
   - Open a post → the **book icon beside the mode picker** → the
     reference panel. **Add File…** → a real PDF from Documents/Desktop
     (this is the TCC-class moment — the panel grant is the access).
     Flip a few pages. Select text in the PDF and **drag it into your
     draft** — it lands as ordinary text (no lineage edge; that's
     QUESTIONS #20, below).
   - **QUIT the app. Relaunch. Reopen the same reference.** It must open
     to the page you left. *This is the cross-launch bookmark proof — the
     one thing that silently broke before the round-1 review fixes and
     that no test can fully verify (tests can't relaunch the app).* If it
     says "the file can't be found," tell the next session — that's a
     finding, not your error.

3. **☐ Carried over from 11a — the phone's one-time updated install**
   (Xcode: Product → Scheme → Run → Release, run to device once). Until
   it lands: **don't create lenses, canvas positions, or block names** —
   ordinary journaling and editing are unaffected. (The mirror is
   already at lockstep v2; the un-updated phone keeps syncing normally.)

4. **☑ The ratify walk — DONE (2026-07-16, via the coordinator).** You
   ratified #20/#21/#22a–b and the build-time calls as shipped, and
   answered **#22c: INCLUDE POOLS** — bulk export now writes
   `Pools/<title>.md` per live pool (built + pinned the same session).
   Nothing left to walk; the resolutions section below is the record.

5. **☐ Kick off Phase 12 when ready** — hardening & perf validation
   (what it is, below). You start it; nothing auto-advances. Note its
   first step wants ~30 minutes WITH you (a read-only copy of your real
   store + some counts — the phase hardens against your real corpus, not
   guesses).

---

## What shipped

**Export (B1).** Posts, readings, and single blocks export as `.md`;
posts also as basic PDF. All exports are ONE-WAY projections of exactly
what the app renders — the same join rules as the editor and the
Fragments bridge (your stored blank lines export byte-for-byte; blank
takes contribute nothing). A fanned block's export puts the chosen take
in the document flow and the other takes under a labeled
`--- Alternates for this block ---` section (your labels quoted;
unlabeled takes numbered). **Bulk export** is the no-lock-in principle
made real: File ▸ Export Library… writes every live post exactly once —
archived posts included under `Archived/`, **pool scraps under `Pools/`
(your #22c ruling at the checkpoint)** — plus per-reading view files.
Nothing in any export path ever writes to your store (pinned by test).

**Import (B2).** Drop `.md`/plain text on the sidebar → a new post,
segmented exactly like a paste (the 2026-07-12 spacing ruling rides:
what you drop is what exports back, byte-for-byte). Drop on the POOL →
scraps in that pool instead. File ▸ Import Files… is the same door as a
panel. The source file is never touched (bytes + modification time
pinned unchanged); one drop = one undo, however many files.

**The reference panel (B3).** Per-post sources beside the draft: the
book icon opens an inspector — PDFs render in PDFKit with **page
memory** (stored as view state on the reference row, synced; the file
itself never syncs — file access is per-machine by design), other files
in Quick Look, URLs in a read-only web pane with "Open in Browser."
Text selected in a PDF drags into your draft as ordinary text. Remove,
reorder, add-by-URL all live in the row's context menu. EPUB,
annotations, and citations remain permanently out of scope — this is a
viewing aid, not a knowledge base.

## The entitlement story (why the review's BLOCKER existed — plainly)

The Mac app runs in Apple's sandbox. Until this phase it had only ever
*read* files you picked — so its sandbox permission said "user-selected
files: read-only." Export is the app's first feature that *writes* files
you point at, and macOS enforces the distinction brutally: **with
read-only permission, the Save dialog refuses to even appear.** Every
export menu item would have silently done nothing in the app you
actually launch — and our tests couldn't catch it, because tests write
inside the app's own container, never through the Save dialog. The cold
review caught it (the same class as 9c's missing network entitlement:
a capability's FIRST use is where its missing permission surfaces).
Fixed by upgrading the permission to read-write, plus a second
entitlement ("app-scoped bookmarks") that lets the reference panel
re-open your PDFs after a relaunch without asking again. A permanent
test now reads the signed app's real entitlements, so this class can't
regress silently. This is also why your checklist item 2 matters: the
save panel appearing at all, and a reference surviving a relaunch, are
the two things only a human in the real app can confirm.

## The review ladder, in brief

Round 1: **1 BLOCKER / 2 MAJOR / 1 MINOR / 3 NIT** — the BLOCKER above;
one MAJOR made the bookmark fallback honest (if the sandbox ever refuses
a durable bookmark, the panel now SAYS the reference won't survive
relaunch instead of failing silently later); the other moved file access
out of SwiftUI's render path (it was re-claiming access on every redraw
— unbounded resource claims; now one claim per selected preview,
released when you move on). Round 2: **1 MINOR / 5 NIT, zero new
high-severity — the ladder closed.** The MINOR was real: round 1's
"one drop = one undo" fix had covered the File-menu door but not the
actual drag-drop door; round 2 caught the overclaim, the fix now covers
the door you'll actually use, and the record was corrected. Every fix
landed with a test that provably failed on the pre-fix code.

**Final counts: core 650 tests / 77 suites · Mac 380 / 68 · mobile
11 / 4 — all green.** No schema change this phase (nothing new to
deploy; the lockstep state is untouched).

## The ratify walk — RESOLVED (2026-07-16, your rulings via the coordinator)

- **#20 — RATIFIED AS SHIPPED.** PDF drag-out is a gesture-style copy
  with no lineage edge (a reference isn't a block, so there's nothing
  for `derived_from` to point from). If you ever want "where did this
  quote come from," that's a schema addition — your call, a lockstep
  event.
- **#21 — RATIFIED AS SHIPPED.** The basic PDF path (system font,
  US-Letter pagination); Phase 13 owns typography.
- **#22a — RATIFIED AS SHIPPED.** A drop on the pool lands IN the pool
  as scraps; the library drop mints the post.
- **#22b — RATIFIED AS SHIPPED.** Bulk export includes archived posts
  under `Archived/`; deleted posts never export.
- **#22c — ANSWERED: INCLUDE POOLS (built at the checkpoint).** Bulk
  export now writes one `Pools/<title>.md` per live pool — your scraps
  in pool order, same join rules, same collision handling; tombstoned
  pools excluded. Pinned by test the same session.
- **Build-time calls — RATIFIED:** includeReadings always-on at the
  bulk face (you were offered a checkbox and kept always-on); read-only
  bookmark scope (references are viewing aids — if a future phase ever
  annotates files, that's the line to revisit); block export's filename
  from the block's handle; the rest (alternates placement/markers,
  reading heading levels, bulk filename scheme, block-export-.md-only,
  the File-menu import twin) stand with the bundle.

## What Phase 12 is (you kick it off)

**Hardening & perf validation** — the phase that proves the promises at
your real scale: the performance invariant re-benchmarked against a
corpus built from your actual store's measurements; a sync soak audit of
your months of real two-device history (byte-identical stores, every
conflict rescue explained, repair rates sane); a decision memo on
tombstone garbage collection (nothing gets purged unless you accept the
memo — it's the system's first deliberately destructive design, so it
arrives as options, not code); the backup restore drill; and the debt
sweep that leaves KnownIssues zero-orphan. Staffing changes: Opus
implements, Fable cold-reviews (the cross-model flow). Its plan is
written and waiting: `notes/plans/phase-12-hardening.md`.

## Where everything is recorded

- The full Stage B record + both review rounds' dispositions: the
  `## Closeout` of `notes/plans/phase-11-remaining-views.md`.
- The master plan row/pointer + the 11b closeout paragraph:
  `notes/DetailedPlanForPhases.md`.
- The open questions: `notes/QUESTIONS.md` #20–#22.
- KnownIssues: export/import/reference rows resolved; typographic PDF
  re-stated under Phase 13; zero rows without owners.
