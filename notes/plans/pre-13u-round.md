# The pre-13u round (EXECUTION PLAN)

**Status: READY — authored 2026-08-30, immediately after the proactive tech-debt sweep.**
Runs after her live `13p-fix` session (Phase 17 entry **17g**) and before **13u1**.

## What this round is — and why it is not a numbered phase

A **round**, on the precedent of the post-13l polish round and the mobile parity round: a bounded,
mixed-roster session between two phases. It carries three Phase 17 entries, a cold review, a canon
amendment, an outbound brief, and one small user-visible addition.

**The vocabulary matters, so it is stated once.** The ROUND is the vehicle — a session with a plan and
a closeout. The **17 entries are the work items it carries**, and they keep their letters and close in
their own file. This round does not become a 17-entry itself, and it is not a phase-table row: only
its one product-visible deliverable (the sample library) earns a mention in the running order.

**Why these things are together.** They share a property rather than a subject: every one is work that
should happen *before* 13u1 opens the editor seam, and none is large enough to hold a phase. Two of
them also feed each other — Act 3 builds the corpus Act 4 measures against.

> **⚠️ FILE-OWNERSHIP TRAP AT KICKOFF.** `notes/plans/phase-17-standing-fixes.md` was being written by
> the concurrent `13p-fix` session when this plan was authored, so this plan deliberately does not
> touch it. **First act of this round: re-read that file** — 17g exists by now, and this round's
> cross-references into it (Acts 1, 4, 5) must be added there, not assumed.

## Reading order (do this first, in this order)

1. `CLAUDE.md` — especially the standing-fixes rule (the master plan is product advancement only) and
   the author-only calls.
2. `notes/ProactiveTechDebtReview-2026-08-30.md` — **the audit table first**, then P39, and the 17c and
   17f entries. Every finding carries its verifier's trace; **where finder and verifier differ the
   verifier wins.**
3. `notes/plans/phase-17-standing-fixes.md` — the philosophy, the standing rules (pin-before-fix), the
   allocation register, and **17g as the other session left it**.
4. `notes/plans/phase-13u-feel-and-polish.md` — the fold section at its end (Act 2 hands work to 13u2).
5. `notes/OverallModel.md` §9 ("how to smell a wrong design") — Act 2 turns on it.
6. For Act 3 only: `Sources/VariorumCore/Operations/Operations+Import.swift`,
   `Operations+Sections.swift`, and `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift`.

**The standing rules bind unchanged:** pin before fix; a pin that passes on both sides dismisses the
item as hollow rather than fixing it; no product invention (unresolved behaviour goes to
`notes/QUESTIONS.md`); schema changes get their own commit; the `Sources/VariorumCore/Sync/` Fable
rider binds any file under it.

---

# The roster

## Act 1 — Cold review of 17g (the `13p-fix` session's work)

A fresh reviewer running `notes/REVIEW_PROMPT.md` **verbatim**, with zero implementation context, over
17g's diff. The isolation is the point: this round must not summarize 17g to its own reviewer.

17g fixed a defect she found **by testing the refreshed 13p install** — provenance that matters,
because it is exactly the class the sweep could not reach (the sweep read code; it ran nothing).

**Obligation:** every finding gets a written disposition in 17g's entry. Anything real and unfixed
lands in `KnownIssuesAndTechDebt.md` with an owner.

## Act 2 — P39: refine the rule, then hand the code fix to 13u2

**The finding, corrected.** CLAUDE.md binds *"cross-feature interactions route through parent
composition, never feature-to-feature calls."* Measured 2026-08-30: **57 directed cross-feature edges
across 8 mutual pairs** (the finder claimed 20). Parent composition **is** honoured — `RootView` is the
only construction site — so only the "never feature-to-feature calls" half is violated. Of the 8 pairs,
**two are real defects** and six are a view rendering a sibling's view or a shared component homed in a
feature folder.

**The author's ruling (2026-08-30): a rule violated 57 times is usually a wrong rule.** This is
OverallModel §9's own doctrine — an operation tortured to express means the schema is wrong, not the
operation.

**What this act does:**

1. **Amend CLAUDE.md** so the prohibition binds **view models, business logic, and lifecycle
   ownership** — never a view rendering a sibling's view, and never a shared component in what is a
   single Swift module.
2. **Write the rationale into the amendment**, not just the rule. The reason is testability and
   isolation: a cross-feature *view-model* reference destroys them; a view reference does not. Without
   the stated reason, the next reader cannot tell a clarification from a relaxation.
3. **Add the positive placement clause** — where a shared view component actually lives. *This half is
   the one that is easy to skip and must not be:* without it, the amendment trades a violated rule for
   no rule, and the tail (`TakeEditCost`, `TagChips`, `MembershipChip`, `NoteDeleteConfirm`) keeps
   growing with nowhere to go.
4. **Hand the code fix forward: EDIT `notes/plans/phase-13u-feel-and-polish.md` to add P39's two real
   items to 13u2's roster** — (a) break the `Library` ↔ `Pool` view-model cycle (Pool stops holding
   `LibraryViewModel`; `duplicateAsVersion` and `archive` become closures passed by `RootView`), and
   (b) stop `Editor/WriteTakesPanel.swift:51` constructing `TakesViewModel`. **13u2 and not here**,
   deliberately: both touch `RootView` composition and `@State` lifecycle, 13u2 is already in those
   surfaces, and scoping them before the rule is refined would build against a rule about to change.

**The test of a good amendment, and it is falsifiable:** under the refined rule, **both real defects
must still be violations.** If either becomes legal, the amendment relaxed the rule instead of stating
it, and it is wrong. Check this explicitly and record the check.

**No code changes in this act.** It is a canon amendment plus a plan edit.

## Act 3 — The sample library: *The Adventures of Sherlock Holmes*

**Her ask, 2026-08-30:** the Sherlock Holmes adventures added to the store as a **book, each short
story its own note, each story a chapter** — so new users get *"a familiar lens through which to
explore the app, while also seeing how fast it is"* — and so she can measure **100k words in a book +
10k words in a note on her own device.**

### Her rulings (2026-08-30 — made after the first draft of this plan asked; they are settled)

**IT SHIPS IN EVERY READER'S STORE. Default-on, not opt-in.** The draft recommended opt-in and she
overruled it, with the reasoning recorded because it is the design argument, not just the verdict:

> *"it'll only be about 10 notes, fewer than the tutorial, and it can be tagged sherlock holmes. it's
> easy to delete if they want but it makes the power of the app clear in a way that the tutorial just
> doesn't — one is made to be digestible, the other is meant to show scale."*

**Two things follow from that, and they are the acceptance bar for this act.** The tutorial and the
sample library have **different jobs**: the tutorial teaches and is deliberately small; Sherlock exists
to make *scale* legible — a real book, real chapters, a 10k-word note that opens instantly. If the
seeded library does not feel fast, this act has failed at its actual purpose and that is a finding, not
a polish item.

**And her structural observation, which is a verification item:** *"the Pool is the library for items
not in a book — that'll be blank for new users."* Because every seeded story is a **member of the
book**, the Pool stays empty on a fresh store, which is the correct first impression. **Check this
explicitly** — a seeding bug that leaves stories bookless would fill a new user's Pool with twelve
strangers on first launch.

**The stories are TAGGED `sherlock holmes`** — her word — so the whole library is findable and
removable as a set.

**Gutenberg handling: standard practice, ratified.** Strip the PG header/footer and ship the
public-domain text with a plain source attribution. The stories are US public domain; the PG trademark
licence attaches to their edition, not to the work.

| # | Decision | State |
|---|---|---|
| A | Which text | *Adventures* (1892) — **12 stories, ~105k words**, which lands on both her targets at once. Her *"about 10 notes"* matches. Confirm real counts at ingest. |
| B | Gutenberg boilerplate | **RULED** — strip, attribute, ship |
| C | Default-on vs opt-in | **RULED — default-on, every reader's store** |
| D | Where it lives | Curated book in the default wing now; **record a line for 13i**: it should become its own wing, removable in one gesture |
| E | Bundle cost | ~600KB of text. **State the measured number at close.** |

### Build shape

Mirror `TutorialSeeder` exactly — the proven precedent (`enum TutorialSeeder` with `discover` /
`findOrSeed` / `restore` / `cleanup` / `seed`, driven from `ShellActions`). A `SampleLibrarySeeder`
beside it, same shape, same idempotence discipline.

Per story: `importPost(title:text:)` — which segments on entry by the global mode, so each paragraph
becomes a block — then `addPostToReading`, `createSection` (one chapter per story),
`assignPostToSection`, and `applyTag` for `sherlock holmes`.

### Traps — and default-on makes the first one serious

1. **FIRST-LAUNCH SEEDING COST IS NOW ON EVERY NEW USER'S CRITICAL PATH.** ~105k words segmenting into
   the low thousands of blocks, plus 12 posts, 12 sections, 12 memberships and 12 tag applications — a
   substantial write that did not exist when this was opt-in. **P2 binds: no DB I/O on the main
   thread**, and this app already has a KnownIssues row for windowless launches and launch-path
   robustness. **Seed off-main, after the window is up, never blocking first paint** — and measure
   first-launch wall time on a fresh store, before and after. A first launch that stalls is a worse
   first impression than no sample library at all, which would invert the entire point of the act.
2. **`importPost` registers a structural undo entry per call.** Twelve calls put twelve "Import"
   entries on the session stack, so a new user's first ⌥⌘Z does something surprising. Check what
   `TutorialSeeder` does and do the same.
3. **Idempotence.** Seeding twice must not mint a second book. `TutorialSeeder.discover` is the pattern.
   This matters more now: the seeder runs for everyone, on every fresh store, including hers.
4. **It is the first time `reading_section` carries a real book at scale** — 12 chapters with real
   memberships. Watch it and say what you saw.
5. **It syncs.** A signed-in new user pushes ~105k words of ciphertext on first sync. Not a blocker;
   worth one line in the closeout because it is now the baseline every account starts from, and **13y**
   is about to design per-account quotas against exactly that baseline.
6. **The phone is a first-class birthplace of stores** (13p, MobileSoul PL-15). A store created ON the
   phone must reach a deliberate answer — seed there too, or arrive by sync. **This is the act's mobile
   parity line**, and default-on is what makes it a real question rather than a footnote.

### What it is for, beyond the content

**This corpus is Act 4's instrument.** Seed it before running 17c so the read-layer measurements happen
against a real 105k-word book instead of a synthetic fixture. That is why Act 3 precedes Act 4.

Report, on her device: book open, scroll, and book-view assembly at 105k; note open and typing latency
in a ~10k-word story; first-launch wall time on a fresh store; and whether P1 holds — cost proportional
to viewport and edit, never to corpus.

## Act 4 — 17c: the read layer's P1 debt

Four findings (P18–P21) in `Sources/VariorumCore/Queries/`. Deliberately split from 13u1's O(N²)
family, which is editor-seam.

**P20 first — it is the sharpest and the cheapest.** The version-history classifier has no index, so
`deleteContainer` walks every post in the corpus **inside its own write transaction**, even for a note
with zero versions: a corpus-scaled hold on the write lock, not merely a slow read. **A local index is
free under SyncSpec §12** — the Postgres mirrors deliberately carry no indexes beyond the PK — so it is
not a lockstep event and needs no deploy window. It is still a schema change: **its own commit**, ahead
of anything using it.

Then P18 (`trayTakes` full-scanning `variant` inside a held observation), P19 (`versionOfNote` N+1 in
the Trash listing) and P21 (`activeFans` one query per block in a Swift loop).

**Measure on Act 3's corpus, before and after, and put real numbers in the closeout.** These four were
traced by reading, not benchmarked — the sweep ran no code. A finding whose pin passes on both sides is
dismissed as hollow and recorded, not fixed.

## Act 5 — 17f: dead code, canon corrections, and pins that cannot fail

Nine items (P42–P50). The cheapest act and the best ratio of effort to future time saved.

**The four test findings are the reason this act belongs in a verification round.** This project's whole
review doctrine rests on the red-on-old pin — so a pin that *cannot* fail is not a weak test, it is a
hole in the mechanism every future review depends on. **P48 is the sharpest:** five of six P1
benchmarks are gated by an absolute 2 ms floor rather than the flatness ratio their own names claim, so
they would not go red if P1 were violated — which is precisely what several sweep findings allege is
already happening, and what Act 4 is measuring.

P46 is a canon correction costing minutes: AppSpec §7's seed comment still says `idle_commit_hours = 24`
where the shipped seed is 2.

**Dead-code items (P43, P45) must be grep-verified before removal**, per the finding's own standard.

## Act 6 — The Fragments encryption outbound brief

Write the outbound brief for the Fragments agent as a dated carry item in
`notes/fragments-bridge-contract.md` — the standing channel, since the Fragments repo is hands-off by
rule and **this round never touches `~/dev/fragments`.**

Content: Fragments' own at-rest/local encryption story beyond the shared journal class, per the running
order's row 3 and 13p's outbound-brief deliverable. 13p already drafted material for her carry —
**read it before writing, and extend rather than duplicate.**

**She carries it. This round does not send anything.**

## Act 7 — Her carried items

> **FILL AT KICKOFF — she supplies these once the session is underway, not before.** Her words,
> 2026-08-30: *"I'll just tell the other session the other items once the session is underway - I have
> to have a bit of time with the app to find them and I can't do that right now while the test suites
> are running because they pop up very annoyingly on my computer screen."*
>
> **So this act starts empty by design, and the round must not treat that as nothing to do.** Two
> consequences for whoever runs it: **(a)** do not schedule this act first — she needs quiet hands-on
> time with the app to find the items, and a running suite steals her screen; **(b)** when the items
> arrive, record each here **in her words**, with a traced mechanism where she has one, and disposition
> each at close like everything else. **An item with no traced mechanism is not ready to be built** —
> it is a note, and it goes to `QUESTIONS.md` or to a later entry.
>
> *(Standing environment note worth carrying: test runs pop windows onto her screen. Prefer running
> suites when she is not trying to use the app, and say when you are about to.)*

---

# Obligations at close

1. **Every item verdicted** — FIXED (naming its red-on-old pin), DISMISSED AS HOLLOW (the pin passed on
   both sides), or DEFERRED with a named owner. Silence on any item is an incomplete closeout.
2. **17c and 17f closed in `phase-17-standing-fixes.md`** with their dispositions, and this round
   cross-referenced from 17g's entry (see the file-ownership trap above).
3. **P39's amendment carries its rationale and its placement clause**, and the falsifiable check is
   recorded: both real defects still violate the refined rule.
4. **`phase-13u-feel-and-polish.md` updated** with P39's two code items on 13u2's roster.
5. **Act 3's measurements reported on her device**, not on a test fixture — 105k in a book, ~10k in a
   note, **first-launch wall time on a fresh store**, and P1 stated as held or not.
5b. **The Pool is verified BLANK on a fresh seeded store** (her structural check — every story is a
   book member), and the `sherlock holmes` tag selects the whole set.
6. **A line recorded for 13i**: the sample library should become its own wing.
7. **MOBILE PARITY LINE** — required by CLAUDE.md's closeout ritual, and **Act 3 makes it a real
   question**: the phone is a first-class birthplace of stores since 13p, so a store created there
   either seeds Sherlock or receives it by sync, and the round must say which. *"Nothing
   mobile-visible"* is not available as an answer for this round.
8. **Anything deferred lands in `KnownIssuesAndTechDebt.md` with an owner.** Never dropped back into
   the sweep artifact, which is a dated snapshot and not a tracking surface.
9. **`/Applications/Variorum.app` refreshed** if any Mac app code changed, per CLAUDE.md — and note
   that she does not quit the running app on request, so coordinate.

# Verification at close

- Core, Mac, mobile and spine suites green, with counts stated against 13p's finals (core 1453/154 ·
  Mac 1843/312 · mobile 513/86 · spine 71/10). **The known intermittent latency pin reds under load —
  re-run isolated before concluding anything.**
- The tutorial spine green (the permanent acceptance script).
- Act 4's before/after numbers on Act 3's corpus.
- Zero `Sources/VariorumCore/Sync/` lines unless the Fable rider was honoured.
- Lockstep marker unchanged at 7 (Act 4's index is local-only; **13y owns the next event**).

# Where this round slots

**After `13p-fix`/17g, before 13u1** — her stated sequence, and the right one:

- Act 1 reviews 17g while that work is fresh.
- Act 2 must precede 13u2, which receives its output.
- Act 3 gives Act 4 a real corpus, and gives 13u1 a realistic tree to open the editor seam against.
- Act 5's honest P1 pins should exist **before** 13u1 changes P1-relevant code, not after.

Nothing here blocks on 13y, 13i, or the mobile project.
