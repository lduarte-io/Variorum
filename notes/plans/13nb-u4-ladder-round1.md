# 13n-b U4 — ladder round 1 (cold review, fable-reviewer, 2026-10-10)

**Scope reviewed:** the U4 unit diff `f4078d61..fce833b1` (46 files, ~3.9k lines) against the
phase plan's U4 brief, AF-11, R-13nb-14/17/18/23/26 and the carried canon. Prior-unit code
treated as settled context except where this diff touches it. The plan carries **no "Review
foci" section** (checked the section map top to bottom) — the implementer's "where to look
first" list was treated as a map, not a bound.

**Verified by my own hands (headless, no stage):** `MCPCarriageActsTests` 16/16 green;
`VariorumMCPTests` whole target 61/8 green (counts matching the record). Fences re-checked
over the range: zero lines in `Sources/VariorumCore/Sync/`, `Server/`, `Persistence/`,
custody, or the editor seam files; zero commit trailers. Mac-side claims (212/19 focused
suites, the walk) rest on the implementer's run + the orchestrator's verification + the U4
LIVE ROUND, which exercised the app half's exact claims through a real client; I re-read the
Mac test sources rather than re-running them.

---

## Findings

### F-1 · MAJOR · `Sources/VariorumMCP/MCPWriteTools+Carriage.swift:213-240` + `Sources/VariorumCore/Operations/Operations+Reading.swift:244-246` · `set_book_rule`'s backfill arm lets a client EXPAND ITS OWN READ REACH to every unshared note matching a rule it writes

- **What:** a rule SET on a rule-less book is classified `.backfill` and **seats matching
  notes as members immediately** (`writeReadingQuerySpec` → `intakeSweep(occasion: .backfill)`).
  A book-scoped grant reaches member notes (`MCPGrantRule.reaches`,
  `Domain/MCPGrantRule.swift:284` — `note.bookIDs.contains(grant.scopeID)`). So the client's
  OWN `set_book_rule` call converts unshared notes into readable members of its granted book,
  en masse — the exact pull that `add_note_to_book` and `file_note_in_chapter` double-decide
  to prevent (the recorded rationale, `MCPWriteTools.swift` `noteIntoBook` doc: *"adding an
  unreachable note to a granted book would pull it into the client's reach"*; U4's own
  `guardBookAndNote` repeats it: *"a note the client cannot reach is never reorganized"*).
  The one-note road refuses; the all-notes road is open.
- **Evidence (traced end to end):** (1) client approved, standing WRITE-NEW grant scoped to
  book B, B rule-less and collecting; (2) note N in B's wing wears tag `percy`, unfenced,
  unshared — `read_note(N)` answers `notShared` (pre-state); (3)
  `set_book_rule(B, rule: {"tag": "percy"})` → `RuleGrammar.read(previous) == .none` →
  `.backfill` → `intakeSweep` seats N (`status='member'`); (4) `read_note(N)` →
  `mcpNoteFacts.bookIDs ∋ B` → the book grant allows → N's full text answers. A book that
  already HAS a rule is two calls away (`rule: null` first — clearing is `.catchUp`, bells
  nothing since a nil rule matches nothing, never evicts; the second call is then backfill).
  Secondary oracle even without the read: the honest member count on `list_books` discloses
  how many notes wear any probed tag. Journals/Private stay fenced (the fence is per-note,
  per-call) — the leak is every UNFENCED unshared note in the book's wing.
- **Why this isn't simply "AF-11 F-1 ruled mirror":** the fork text acknowledged the intake
  runs ("seats/bells the rule's intake made STAY") but never named the reach consequence; and
  the backfill occasion's own canonical justification is **"birth = intent"** (AppSpec §9 /
  the choke point's doc) — HER authorship intent, which an agent-authored rule does not
  carry. The occasion whose rationale fits an agent's rule write is the CATCH-UP (bells; her
  judgment seats). Where the ruling is silent on this product edge, the standing recorded
  design rationale (the U2 double-decision) is the nearest truth, and the diff contradicts it.
- **Red-on-old pin:** the four-step trace above as a `MCPCarriageServerTests` test — after a
  granted book's rule write, `read_note` on a previously-unshared matching note must still
  refuse (red on this diff: it answers the text).
- **Proposed fix (conservative, one line + pins):** wire-initiated rule writes pass an
  occasion override so the choke point BELLS instead of seats on the backfill case too
  (matches wait at Arrivals; her seat is the reach-expanding act; the answer already carries
  the Arrivals vocabulary). Her own Save keeps backfill untouched. If instead the final call
  is that a book-scoped write-new grant legitimately covers rule-driven membership drift,
  that is HER call — it belongs in the merge QUESTIONS bundle with this trace attached,
  not in silence.

### F-2 · MINOR · `Sources/VariorumMCP/MCPWriteTools+Carriage.swift:194-211, 250-262` · `file_note_in_chapter`'s NOTE arm never raises the just-in-time ask

- **What:** the snapshot path (`into(.book(bookID))`) decides only the BOOK (with
  `MCPAsking`); the NOTE is decided only inside `guardBookAndNote`, whose refusal throws
  `Self.refused(onNote, .note)` (`MCPWriteTools+Edit.swift:304`) — bare words, no `onAsk`,
  `asked: false`. The sibling two-sided act `add_note_to_book` (`noteIntoBook`) snapshot-decides
  BOTH sides and queues the ask per AF-6 (`rungTooLow`/`fenced` gain the asked sentence; an
  unshared existing target queues silently for her).
- **Evidence:** client with write-new on book B and read-only on member note N calls
  `file_note_in_chapter(N, B, S)` → refusal `"This client may only read here."` with no ask
  queued and no asked sentence — she never hears it; the same client calling
  `add_note_to_book(N, B)` queues the ask. Mechanism read directly from both paths.
- **Red-on-old pin:** `h.asks` empty after the refused filing (red), non-empty after the fix;
  plus the asked-sentence suffix on the rungTooLow words.
- **Fix:** decide the note at snapshot beside the book (noteIntoBook's exact shape, spendsAfter
  false), keeping `guardBookAndNote` as the in-transaction re-check.

### F-3 · MINOR · `Sources/VariorumMCP/MCPReadTools.swift:130-139` + `MCPNoteStructure.swift:274` · a version read's `with_lineage` stubs far sides the client CAN read as `beyond_grant` — including the live note whose grant authorized the call

- **What:** the version branch passes `standing: nil` into `MCPNoteStructure.read`, so
  `farSides`' readable-note arm (`else if let standing …`) can never fire. A version's blocks
  carry `version_of` edges to the LIVE note's blocks; those far sides classify: placed ≠
  version, `isVersionHistory(liveNote, of: version)` false, standing nil → `.beyondGrant`.
- **Evidence:** `read_note(note_id: N, version_id: V, with_lineage: true)` on a granted note N
  answers `{"relation": "version_of", "beyond_grant": true}` for N's own blocks — a false
  claim (the client holds N's grant; it just used it), and it makes lineage on a version read
  nearly useless, its most interesting far side being exactly N. Conservative in direction
  (no over-disclosure), wrong in words, and against P-13nb-U4-7's "a block of a note the
  client can read (`note_id`)" arm.
- **Red-on-old pin:** a version read's lineage entry for the live note's block carries
  `note_id` (or a this-note arm), not `beyond_grant` — red today.
- **Fix:** pass the real `standing` to the version read (the `books` answer can stay
  suppressed independently), and classify `placed == the live noteID` explicitly.

### F-4 · MINOR · `App/Variorum/Variorum/Features/MCP/MCPNavigator.swift:45-58,64-75` + `MCPDoor.swift:452-460` · a timed-out takes/lens delivery still answers `{"shown": true}`

- **What (the implementer flagged it; confirmed):** for `.takes`/`.lens`, `deliver` opens the
  note and waits ≤2 s for its detail to register; on timeout it returns having opened the
  note but neither parked the landing nor switched the mode — and `agentShow` returns
  `.navigate` unconditionally, so the client is told shown: true for a half-delivery. The 2 s
  suspension also sits between the etiquette look and the mode switch (backgrounding the app
  mid-wait doesn't stop the tail).
- **Evidence:** `deliver`'s `guard await open(…) else { return }` discards the failure;
  `agentShow` has no channel for it. Mechanism read directly; reproducible headless with a
  standing provider + no registered detail (the note never registers → the answer still says
  shown).
- **Red-on-old pin:** fake-hook test where the detail never registers → the answer must not
  claim shown (red today).
- **Fix:** `deliver` returns Bool; `agentShow` answers an honest refusal for the timeout
  ("the note didn't open in time — nothing more was moved"), optionally re-checking standing
  after the wait.

### F-5 · NIT · `Sources/VariorumMCP/MCPNoteStructure.swift` (`lenses`/`versions`) · silent 200-caps without the tray's `truncated` marker

The tray fetches `carriageCap + 1` and says `truncated`; `lenses` and `versions`
`prefix(carriageCap)` silently. A 201-version note's listing drops one with nothing said.
Fix: the tray's cap+1 shape on both. (P-13nb-U4-5's flag covers only the tray's lists, so
this is completeness, not a broken pin.)

### F-6 · NIT · `Sources/VariorumMCP/MCPNoteStructure.swift:357-377` · take ancestry's edge-readings of the live-endpoint rule

A parent whose BLOCK is dead answers `parent_beyond_grant: true` (farSides has no row → the
stub) rather than being left out; a tombstoned parent VARIANT on a live block still answers
`parent_take_id` (the `parents` SQL joins variants with no `deleted_at` check). No oracle
opens (dead collapses INTO the stub class; the id disclosed is within the note's own grant),
but P-13nb-U4-7's "a dead far side is left out" and the code diverge in both directions.
Record-fix or a liveness filter — either way one sentence or one WHERE clause.

### F-7 · NIT · plan §PROVISIONALs (P-13nb-U4-8) · "while the dial and the outflow still land" under-describes the pinned combined-call behavior

The pinned behavior (`MCPCarriageActsTests:316` — "nothing half-lands") is: a COMBINED call
carrying a rule on a malformed-stored book refuses WHOLE (dial/outflow in that call do not
land); a dial/outflow-only call lands. Her Save, by contrast, would land dial+outflow while
`needsWrite` silently skips the rule — the wire has no face to grey the rule half, so
refuse-whole is the defensible mirror, but the provisional's sentence reads as if the other
fields land in the same call. One clause ("a call without a rule still lands") keeps her
ratification honest. Record-only.

---

## Dispositions (round 1 — pending the cross-model flow)

| # | Severity | Disposition |
|---|---|---|
| F-1 | MAJOR | pending |
| F-2 | MINOR | pending |
| F-3 | MINOR | pending |
| F-4 | MINOR | pending |
| F-5 | NIT | pending |
| F-6 | NIT | pending |
| F-7 | NIT | pending |

---

## Clean bill (checked and found solid)

- **The in-transaction guard discipline (AF-10 (a)) on every new act:** `put_back` (tray
  home re-resolved on the act's own rows; tray membership via `Queries.trayBlocks/trayTakes`
  — her panel's exact population, cascade victims and purge intents excluded; the
  already-back case deliberately falls through to the op's own `blockNotDeleted` /
  `variantNotDeleted`), `save_version`, `set_entry_date`, `set_book_rule`,
  `file_note_in_chapter`. Every once-grant spend is inside the act's transaction, so a
  refused act's spend rolls back (traced through `trayGuard`/`guardBookAndNote` +
  transaction semantics).
- **The self-review fix (`61f9f48e`) is real and right:** `guardBookAndNote` decides book and
  note on ONE standing read and spends the deduped union — the once-wing-grant pin
  (`aOnceWingGrantFilesANoteOnceAndIsSpentOnce`) covers it.
- **The AF-11 F-4 RIDER holds:** the beyond-grant stub is byte-identical across unshared,
  journal-fenced and scrap far sides (pinned with sorted-keys serialization,
  `lineageAndAncestryAreExactAndBeyondTheGrantIsOneUniformStub`), carries no id/title/kind/
  origin_op/stamp (the `continue` before those fields — read directly), and the fenced note's
  id appears nowhere in the answer. Dead far sides are omitted from lineage (no row under
  `b.deleted_at IS NULL`).
- **`set_book_rule` mirrors her Save where it was ruled to:** same three writes in her order
  through the extracted row functions (`writeReadingIntakeSeating`/`writeReadingOutflow`/
  `writeReadingQuerySpec` — byte-identical bodies, their original suites untouched), her
  change tests (`needsWrite`'s structural equality; malformed-stored never overwritten),
  gathering unreachable (one answer), legacy terms refuse at parse, finished/sealed/archived
  LAND with `intake_paused` said, adopt-or-mint by path in the book's wing (dangling wing →
  Home, the app-wide P-13id-U5-2 rule), undo restoring the three columns raw with seats kept
  (§19) and never running intake. (F-1 above is about the occasion classification, not the
  mirror.)
- **The two U1 list flips (P-13nb-U4-3)** land with the honest-count pin updated and
  justified in place; `recencyPage`'s `include_archived` lifts only the archive fence, never
  the version fence (the ruled classifier `archived_at = created_at`, canon's own shorthand);
  reach untouched (pinned: an archived note answers by id).
- **Versions on the wire ride the note's grant exactly:** `version_id` checked by
  `isVersionHistory` (version_of-edge-anchored, not classifier-only) AFTER the note's decide,
  refused with one answer for a foreign version; a version has no facts of its own (reads as
  unshared by id — pinned); `saveVersion` is `mintNoteVersion` byte-shared with her door
  (classifier shape, one clock read, seal-insurance ordering untouched).
- **`show_in_app` (AF-11 F-3):** decided at READ on the target, never spending a once grant
  (pinned; no `consumeMCPOnceGrant` call exists in `MCPShowTool`); misaddress checks run
  AFTER the grant decision (no oracle); the pure verdict pinned at the seam; the app's
  standing read (`NSApp.isActive` + `WindowRegistry.entry(for: NSApp.keyWindow)` kind full)
  on the main actor (`MCPDoor` is `@MainActor`); refuse-never-queue pinned headless and
  verified live; HER press path (`openShow`/⌥⌘O) deliberately ungated and window-raising via
  `creationRouter` (P-13nb-U4-14).
- **The offer door (AF-11 F-2):** the line stays a RECEIPT (quiet-line kind pinned, never
  promoted to toast), carries one "Open ›", W-1's middle-truncation only when a door rides
  (door-less receipts keep tail truncation), `lastShow` session-scoped and cleared at detach
  (pinned), ⌥⌘O registry-declared with the collision sweep recorded at the chord's binding,
  alive under receipt-style off (pinned), the registry walk's context grown.
- **Navigation is composition over her roads:** `ShellRouter.adopt` + the 13o find seed
  verbatim (pinned: `BlockLanding` with `EditorFindSeed(needle:steps:)`), see-takes pair,
  the new `LensLanding` with the same post-stamped one-shot hygiene as `pendingTakesLanding`
  (cleared on detail change, mode change, reset — read in `CommandRouter`), Outline's
  chapter landing through `BookView.revealSectionID` one-shot. Zero editor-seam files
  touched; no decision-bearing broadcasts (P-4).
- **The J8 fixes are red-on-old by construction:** `lockedReading` and `blockNotDeleted`
  had no table words (confirmed: the diff ADDS the only entries); the pin asserts the exact
  sentences; the live round heard the finished-book sentence verbatim through a real client.
- **The answer-encoder guard:** both server `encode`s and the show tool's check
  `isValidJSONObject` before `JSONSerialization` — the uncatchable-exception class closed.
- **Rung proofs grown as the ritual:** the suggest-rung PROOF and edit-half PROOF now drive
  every carriage door + `show_in_app` against her rows byte-identically (snapshot widened to
  dates, Collecting columns, filings); the catalog walk pins the three handler sets disjoint
  and the carriage tools listed at their rungs only (P-2 on the wire).
- **Sync shape:** every new write is an ordinary row write through existing ops' row work on
  synced tables (outbox triggers capture them as any app write); the undo's raw
  three-column restore is an ordinary UPDATE (sync never learns of undo, as ruled); no
  schema, no `Sync/`, no custody, marker untouched.
- **P1:** every new read is ∝ the note (tray/lenses/versions capped, lineage batched over
  the note's edges with batched far-side facts), every write ∝ the act; no word-level
  tracking anywhere; no text copied across entities outside her own ruled ops
  (`mintNoteVersion`).
- **Copy:** sentence case throughout the new strings; no shouty caps; the one Title Case
  string is a menu verb (the menu's own idiom); all new sentences marked 13s-a-sweepable.
