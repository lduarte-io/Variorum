# VX-805 — the journal cluster: author handoff

**STATUS at writing (~06:10, overnight):** all nine members built and verified; the ladder's round 1 found NO blocker/major (round 2 in flight); canon deltas landed on the branch; the merge-gate whole-target window and the merge itself follow round 2 (the coordinator serializes; this line is updated at merge). Everything below is PROVISIONAL under your overnight directive — ruled to the most spec-defensible option, built, pinned, and bundled here for your morning pass.

## HER MORNING BUNDLE (the checklist)

**1. The one durable-semantics call — P-805-B2, the deleted-Journal mark.** Your delete of the daily Journal now stamps its tombstone `reading.profile = 'daily_deleted'` so sync can tell YOUR delete from a keeper retirement (the no-backfill law demanded a discriminator; options and the full ruling are in the run record's proposal + ruling sections). It is NOT DDL — a new value in the unconstrained plain column, dead rows only, no migration, no marker bump, **no mirror deploy needed** (the mirror's column is plain `text`, verified). The SPELLING is yours: `'daily_deleted'` — a rename is cheap until a release ships it. Bounded mixed-fleet consequence, also yours to bless: an OLD build (1.1/phone) restoring a deleted Journal from Trash gets a plain trait book, not THE Journal, during the upgrade window (new clients normalize it; nothing is lost or misfiled).

**2. Try the new behaviors (all walk-verified on the dev store tonight):**
- Move the daily Journal to another wing (right-click · ⌘K · ⌥⌘L); ⌘J follows it and switches the app's wing with a receipt.
- Delete the Journal (Delete now draws beside Archive) — the ordinary book confirm, no special line (P-805-B8, yours to re-word if you want one); its notes stay; the next ⌘J mints a fresh Journal where you stand.
- Put back a deleted Journal beside the new one — it returns as a plain journal-trait book (R-805-2 exactly as you ruled).
- The Journal's "+ new entry" and ⌥⌘N now mint a FRESH entry every press (several a day); ⌘J still opens the day's FIRST (earliest-created member).
- ⌥⌘J shifts a dated note's date a day earlier; the receipt speaks the day in the app's voice ("Now dated Nov 3.").
- New Book is a sheet now — Esc and a drawn Cancel work (the macOS 26/27 alert never drew its Cancel; that was VX-561, confirmed by your own Esc press).

**3. Wording asks (quick yes/no/replace):**
- **P-805-B4** — the field guide's lesson 9 second sentence + the archive caption now name deletion: "…delete it and the next day's entry starts a fresh one." (alternatives in the record: phone-local caption, or "…deleted on the Mac").
- **P-805-B5** — the wire's two refusal sentences (move: "…only the author moves it, in Variorum."; delete: "…archive_book puts it away; it comes back when a day arrives.").
- **P-805-A3's helper line** for ⌥⌘J ("date the note you're in a day earlier — for an entry written after midnight…").
- Pre-existing nit found at the walk: the plain-book delete confirm's singular arm ("its 1 note stay where they are") doesn't conjugate.

**4. Decisions logged as PROVISIONAL (full texts in the record; they land in QUESTIONS at the merge):** P-805-A1..A5 (Unit A: trait-door nil, chord sweep, receipt wording, SF-1 context edit, the clearing pass's N+1-by-design) · P-805-B1..B8 (Unit B: restore-vs-remint converges as the race; the sentinel; cross-wing arrivals wait; lesson-9 wording; wire wording; the day's entry lives beside the Journal — after a delete, ⌘J in another wing makes that day a second entry there; the mend's occasions tightened to protect your deliberate move-outs; the plain delete confirm) · P-805-C1..C3 (Unit C: what "first" means for ⌘J — members first, notebook-shape fallback; New Entry refuses before minting on a book that can't take it; the comes-back rides New Entry).

**5. Tickets:** all nine members close at the merge. **Born:** VX-857 (the book-spans-wings general class — the cross-wing mend is Journal-only per your ruling; the general class + the ladder's straggler-container corner folded in; needs your scope call). **Canceled:** VX-615 (duplicate of VX-611). **Flagged for triage, unswept:** any other 3+-button text-field `.alert` may drop its Cancel the same way VX-561's did (its own ticket if you want the sweep).

**6. The release window:** this run needs NO mirror deploy and shipped NO DDL; the held 805+808 lockstep window concerns VX-808's half only. The release-ready window (v1.2 PROVISIONAL, artifacts only, NO site publish) belongs to the LAST merger of tonight's wave per the coordinator's plan.

## FOR A LATER READER

The run record `notes/plans/fixes/vx-805-journal-cluster.md` is the one record — its FOR A LATER READER section carries the settled mechanisms; §10 carries the ladder. The nine members: VX-799 (one_block seed retired + clearing pass), VX-832 (picker opens on creation day), VX-587 (⌥⌘J shift-a-day), VX-845 (copy roads keep the day), VX-561 (New Book sheet), VX-435/436 (the Journal movable + deletable — ops, R-805-2 restore, the sync half: the `'daily_deleted'` discriminator + three belts + drain guard + wing-aware keeper + the cross-wing mend + amendment 7's live-sentinel demotion, the shared wire fences), VX-797 (fresh mints + ⌘J-first), VX-615 (canceled dup). Canon deltas landed on the branch (AppSpec §7/§9/§12, OverallModel §7, SyncSpec §7, SurfaceContracts, MCPSpec); `Tools/canon-size`: 132,685 / 150,000. Evidence: the convergence matrix (JournalWingConvergenceTests, 22 scenarios, per-belt behavioral-revert red-on-old), full core 3703/506 green, four stage windows (records in §5/§10), the ladder (§10).

**MOBILE PARITY:** the phone's Today door inherits the day's-first lookup and the beside-the-Journal wing through shared core; the phone KEEPS Archive in Delete's place (its own face) and has no fresh-mint New Entry until the mobile catch-up — a MobileSoul ledger row rides this closeout.

**The vx-809 merge seam (whichever merges second reconciles):** `OperationError.dailyJournalIsHomeOnly` is retired → `dailyJournalMovesOnlyByHand` (loud compile in vx-809's BookWingMoveTests + book-move op); vx-809's `move_book_to_wing` routes through `Operations.refuseMovingTheDailyJournalOnTheWire` inside its transaction, keeping its tool-level pin; the DuplicateDay seam (809 widens the class, 805 the call sites) re-runs the date tests; the registry overlap re-runs CapabilityRegistryTests + ShellChromeTests.
