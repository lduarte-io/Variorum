# VX-381 — ladder round 1 (cold review, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer`, `notes/REVIEW_PROMPT.md` verbatim with {PHASE} = VX-381.
**Diff:** `git diff origin/main...HEAD` in `~/dev/variorum-vx-381` (merge base `5fb276a12`, branch tip `deab75ad2`).
**Scope check (first, per the brief):** the diff does NOT reach Fable's mandatory scope — no editor seam, no
custody/Keychain code, no `Sources/VariorumCore/Sync/`, no schema, no change to a default's meaning (detail in
the clean bill). This round stands as an opus-reviewer round.

**Status:** COMPLETE — 2 BLOCKER · 1 MAJOR · 2 MINOR · 6 NIT. No "Review foci" section exists in the plan file.
The severity-ranked index is at the end; the findings below are in discovery order.

## Findings (discovery order — see the severity-ranked index at the end)

### F-1 · BLOCKER (P1 — the prompt's full-severity class) · `Sources/VariorumCore/Operations/Operations+Tag.swift:224` and `:235`

**What's wrong.** The tag-delete inverse (`revertTagDeletion`, new in this diff) revives applications with
`AND post_id IN (SELECT id FROM container WHERE deleted_at IS NULL)` and
`AND block_id IN (SELECT id FROM block WHERE deleted_at IS NULL)`. A non-correlated `IN (subquery)` is
MATERIALISED by SQLite: the whole `container` (resp. `block`) table is scanned into an ephemeral list once per
statement, i.e. once per revived tag that has at least one candidate application. The undo's cost therefore
scales with the corpus (every container / every block in the store), not with the act's size (the applications
of the subtree's tags) — P1's banned shape.

**Evidence (traced, measured).** `EXPLAIN QUERY PLAN` of the exact post_tag statement on the shipped index set
(`uq_post_tag_live`, `idx_post_tag_tag`, container PK):
`SEARCH post_tag USING INDEX idx_post_tag_tag (tag_id=?)` · `LIST SUBQUERY 1 → SCAN container → CREATE BLOOM
FILTER` · `CORRELATED SCALAR SUBQUERY 2 → SEARCH twin USING INDEX uq_post_tag_live`. Timed on a scratch store
with 1,000,000 containers and 20 dead-on-stamp applications: **0.439 s** for the shipped form vs **0.0005 s** for
the correlated form `AND EXISTS (SELECT 1 FROM container c WHERE c.id = post_tag.post_id AND c.deleted_at IS
NULL)` (plan: `SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)`). The `block_tag` twin scans `block` —
the store's largest-but-one table (every paragraph) — so a subtree undo over block-tagged scraps pays one full
block scan per tag. (The scan is skipped only when a tag has zero candidate rows — SQLite runs the list subquery
lazily — so the common case, a tag that was actually worn, always pays it.)

**Pin (red on old, feasible).** The house's own plan-pin idiom (`ReadLayerP1Tests` — `EXPLAIN QUERY PLAN` +
`#expect(!plan.contains("SCAN …"))`): assert the two revival statements' plans contain neither `SCAN container`
nor `SCAN block`. Red on the shipped SQL, green on the correlated form. (A behavioural pin cannot see it — the
rows written are identical — so the plan pin is the honest one; it is NOT hollow.)

**Proposed fix.** Replace both `IN (SELECT id …)` guards with correlated `EXISTS (SELECT 1 FROM container c WHERE
c.id = post_tag.post_id AND c.deleted_at IS NULL)` / `EXISTS (SELECT 1 FROM block b WHERE b.id =
block_tag.block_id AND b.deleted_at IS NULL)`. Same rows, O(applications · log N).

**Note (not this diff's lines — for a ticket, not this fix).** The pattern is COPIED from shipped restore code
with the same shape: `Operations+Container.swift:729/738` (restoreContainer's canvas/lens revival) and
`Operations+Placement.swift:311` (restoreBlock's canvas revival). Same class, pre-existing; worth one Debt
ticket (Performance) so the house pattern stops propagating.

### F-2 · BLOCKER · `Sources/VariorumCore/Operations/Operations+Tag.swift:199–246` (`revertTagDeletion`) × `:60–98` (`renameTag`)

**What's wrong.** The undo revives a tag row with the materialized `path` it had at delete time, but the path
is the model's ONE deliberate denormalization (AppSpec §7: "`renameTag` rewrites the subtree's paths") and
`renameTag` rewrites only LIVE descendants (`:88` — `WHERE deleted_at IS NULL AND wing_id = ? AND substr(path,…)
= ?`). So a parent renamed while its child lay dead leaves the child's stored path stale, and the undo makes that
stale row live under the renamed parent. The inverse checks the parent is LIVE (`:210–213`) and checks the OLD
path for collisions (`:216`), but never that the old path still agrees with the parent's current path.

**Mechanism (traced from her own doors — Settings ▸ Tags, ⌥⌘Z):**
1. `life` (L, path `life`) ⊃ `goals` (G, path `life/goals`, parent L); a note wears G.
2. Delete Tag on G → pass `[G]`, stamp S; G dead with path `life/goals`.
3. Rename L → `home`: L.path = `home`; the descendant UPDATE skips G (dead) — G.path stays `life/goals`.
   (`renameTag` registers no undo entry, so Delete Tag is still the stack's top.)
4. ⌥⌘Z "Undo Delete Tag" → `revertTagDeletion`: G is dead on S ✓, its parent L is live ✓, wing live ✓,
   `ensureNoLiveTagPath("life/goals")` finds nothing ✓ → G revived: **parent_id = L (`home`), path =
   `life/goals`.**

**Probed** (a throwaway test in a scratch copy of the branch, outside the repo — exactly steps 1–4 plus a
gathering on `.tag(L.id)`): before the delete the gathering showed the note; after the undo the row reads
`[path:"life/goals" deleted_at:NULL parent_id:<L>]` and the gathering on `#home` shows `[]`; after `deleteTag(L)`
G still reads `[path:"life/goals" deleted_at:NULL]` — live under a dead parent.

**Consequences (each traced):** (a) subtree matching is broken — `ruleSQL`'s tag test
(`ReadingAssembly.swift:766–774`) matches `applied.path = root.path OR substr(applied.path,…) = root.path || '/'`,
so a gathering/living book on `#home` no longer shows the notes wearing G, and search/tag listings read a path
whose head (`life`) no tag holds; (b) a later Delete Tag on L tombstones only `home` + the `home/` prefix
(`tombstoneTagSubtree`, `:144–157`) — G stays LIVE under a DEAD parent, the very "no live tag under a dead
parent" rule P-VX381-U2-4 cites; (c) a later rename of L never reaches G again (prefix mismatch) — the corruption
is permanent and syncs (plain CAS rows) to every device. A pass rooted deeper (`life/goals` + `life/goals/2024`)
revives the whole stale chain.

**Why the shipped evidence missed it.** No pin renames a tag between the delete and the undo
(`TagDeleteUndoTests` — eight scenarios, none touches `renameTag`), and `InvariantSweepTests`' predicates
(`:76–116`) check applications→tag liveness only — there is NO tag→parent or path-coherence predicate, so the
U2 self-assessment's "the sweep exercises the entry against the no-live-row-under-a-dead-parent invariants" is
narrower than it reads (it covers `post_tag`/`block_tag`, not `tag`→`parent`).

**Pin (red on the branch tip).** `TagDeleteUndoTests`: L ⊃ G, apply G to a note, delete G, `renameTag(L,
"home")`, undo → expect G live with `path == "home/goals"` AND a gathering on `.tag(L.id)` assembles the note
AND, after `deleteTag(L)`, G is dead. Red today on all three. A sweep predicate (`tag` live ⇒ parent live AND
`path = parent.path || '/' || name`) would also catch the class at random.

**Proposed fix.** On revival, RE-DERIVE the path from the live parent (`parent.path + "/" + tag.name`; a root
keeps `name`) — walking the pass parents-first, which `ORDER BY path` already gives since the delete-time paths
were coherent — run `ensureNoLiveTagPath` against the DERIVED path, and write it with the revival. (The quiet
alternative — treat a changed parent path as divergence and leave the tag dead — would silently eat her undo for
an ordinary rename; not recommended.) The redo needs nothing: it re-deletes by the CURRENT path, which the
revival keeps coherent.


### F-3 · MAJOR · `App/Variorum/Variorum/Registry/ShellActions.swift:189–193` × `App/Variorum/Shared/OpsRefusalTable.swift:428–431` (the P-VX381-U2-3 refusal's face)

**What's wrong.** P-VX381-U2-3 (sustained) makes the Delete Tag undo REFUSE with `duplicateTagPath` when a live
tag now holds the path, and keeps the entry on the ground that the refusal is "resolvable — rename hers, undo
again". But no refusal table words `duplicateTagPath`: the shared table (`OpsRefusalTable.swift` `words(for:)`)
and the Mac's own arms (`Registry/OpsRefusalCopy.swift:408–` `macWords`) have no arm for it, so
`OpsRefusalCopy.message(for:)` falls to `"Refused: \(error)"` (`OpsRefusalTable.swift:430`). The ⌥⌘Z door
(`ShellActions.structuralUndo`, `:189–193`) wraps it: the toast she sees is

`Undo failed: Refused: duplicateTagPath(path: "work")`

— a raw enum print (the class this house keeps retiring: `OpsRefusalTable.swift:135/158`'s own comments), and it
never tells her the road the ruling depends on (rename the tag that holds the name, then undo again). Only the
Settings ▸ Tags model words this case (`TagsViewModel.message`, "A tag named “work” already exists."), and that
model is not on the undo road. The phone's undo door (`MobileUndoDoor.refusal`, `:297–305`) falls back to
`String(describing:)` after the same shared table — it prints `Undo failed: duplicateTagPath(path: "work")`; one
shared-table arm fixes both platforms.

**Mechanism.** `TagDeleteUndoTests.aLiveTagHoldingThePathRefusesAndKeepsTheEntry`'s exact state (delete `work`,
create a new `work`) → Edit ▸ Undo Delete Tag → `revertTagDeletion` throws at `Operations+Tag.swift:216` →
`ShellActions.swift:192` → the string above. Reachable from her ordinary doors (delete a tag, make one with the
same name, ⌥⌘Z).

**Pin (red on the branch tip).** An app pin over the Mac door's words for this refusal —
`StructuralUndoCopy.undoFailed(OpsRefusalCopy.message(for: OperationError.duplicateTagPath(path: "work")))` must
not contain `Refused:` / `duplicateTagPath`, and should name the road. Red today. (Not hollow: the string is
built from the shipped tables.)

**Proposed fix.** A shared-table arm for `duplicateTagPath` in her register, naming the resolution, e.g. "A tag
named “work” already exists — rename it, then undo again." (wording PROVISIONAL for her bundle — the undo road
is the only one that reaches the generic table; the Settings model keeps its own words).

### F-4 · MINOR (pre-existing sibling of VX-241 — ticket, not necessarily this run) · `Sources/VariorumCore/Operations/Operations+SmartCollect.swift:76–81, 184–194` × `App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift` `collectReceipt` / `MembershipChoice.swift` `AddToBookCopy.collected`

**What's wrong.** VX-241 made R98's receipt honest about ONE way a gathering can fail to show a just-collected
note (archived). The other is HIDE-OWNED: `matchesRule` (`Queries.postMatchesRule`) has no
`ownedElsewhereExclusion`, while the assembly composes it when the gathering hides owned notes
(`ReadingAssembly.swift:675–679`; `OwnershipQueries.swift:310–331`). So collecting an OWNED note into a
hide-owned gathering applies the tag and the board says "Tagged #a — the gathering shows it now." (and a repeat
says "Already showing — it matches this gathering's rule.") while the gathering shows nothing.

**Evidence (probed on a scratch copy of the branch, not the repo):** owned book holding note N; gathering G on
`#a` with `setReadingHideOwned(G, true)`; `collectPostIntoSmartReading(N, G)` →
`SmartCollectResult(appliedTagPaths: ["a"], alreadyMatched: false, gatheringArchived: false, starred: false)`;
`assembleReading(G)` → `[]`. The receipt family's own premise (VX-241: "the receipt must not say it shows the
note now") is false here. Pre-existing — the old receipt said the same — so this is the same class VX-241 fixed
for one cause, not a regression.

**Pin.** Core: the result reports whether the gathering's ASSEMBLY will show the note (e.g. a `gatheringShowsIt`
read inside the transaction through the assembly's own predicate incl. hide-owned) — red today for the probe's
state. App: the board's receipt for it never says "shows it now".

**Proposed fix / disposition.** Generalise `gatheringArchived` into "the gathering shows it" (archived OR hidden
as owned) with the honest tail for each cause — or ticket it (Books, Low/Medium) and name it in the handoff beside
VX-241 if the orchestrator keeps the run's scope to the archive.

### F-5 · MINOR (ruled — R-VX381-A4; recorded so the merge's triage sees the live text) · `App/Variorum/VariorumMobile/Features/Write/MobileMembership.swift:124–131`

**What it does after this merge.** The core VX-249 change reaches the phone unchanged: a ★-rule collect there
now SUCCEEDS — starring the note past the 15-star cap (cap-exempt) — where it used to refuse honestly ("can't take
this note: tagging alone can't satisfy its filter"). The phone's receipt is
`"Added by tagging \(paths.joined) — “X” collects by filter."`, so a star-only collect reads
**`Added by tagging  — “X” collects by filter.`** (a double space, and it names a tagging that did not happen and
not the star that did). VM-21 exists and carries the star case (checked on the board: Backlog, Bug/Confirmed,
no priority). Nothing to fix in this run under the ruling; recommend VM-21 get a priority at the merge triage,
since the phone moves from an honest refusal to a false receipt plus a silent star, and that the MOBILE PARITY line
quotes the string.

### F-6 · NIT (an unrecorded PROVISIONAL) · `Sources/VariorumCore/Domain/GatheringMint.swift:288–291` via `Operations+SmartCollect.swift:131–135`

R98's collect now takes an any-of group's FIRST SATISFIABLE option — so for a rule `★ OR #a` it STARS an existing
note rather than tagging it (probed: `SmartCollectResult(appliedTagPaths: [], …, starred: true)`). Consistent with
the mint's ratified P-VX217-d, but for an EXISTING note the star is the heavier side effect (it joins her Starred
section, cap-exempt) where a tag would have served (the old R98 skipped a ★-bearing group as "mixed" and its probe
refused an unstarred note, so there is no prior behaviour to match — the choice is new). The run record's
PROVISIONALs (P-VX381-U2-1/2) don't name it. Recommend one line in her bundle (prefer a tag option over ★ for the
collect door, or keep rule order).

### F-7 · NIT · `App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift` `taggedWhileArchived` (`?? "Tagged "`)

`taggedWhileArchived([], starred: false)` builds `"Tagged  — the gathering shows it once it's unarchived."`
(double space, nothing tagged), while the live arm's same case (`shownByMint([], false)`) says "Added to the
gathering." Unreachable today (an empty plan with `alreadyMatched == false` means the planner and the belt
disagreed, and the belt throws), so not a bug — but the two arms of one family disagree on the empty case. Give
the `nil` arm the live arm's shape, or make `wore` non-optional for the archived arm.

### F-8 · NIT (cleanliness) · `GatheringNoteDoor.swift:65` · `MultiBookEditNote.swift:65–78`

`GatheringNoteDoorCopy.cannot(_:)` is now the identity function (one caller, `BookStructureModel.swift:808`) —
inline it or say why the seam stays. `MultiBookEditNote.divergeTarget`'s `.first { $0.kind == .book }` and its
doc line "nil where every membership is derived" are vacuous now that the trigger passes `memberBooks` (books
only, and ≥ 2 of them whenever it speaks); a one-line doc correction keeps the next reader from hunting for the
nil case.

### F-9 · NIT (copy — route to VX-216 with the chip's voices) · `Operations+SmartCollect.swift:136–145`

The collect door now decides through the SAME planner and the SAME `Blocker` as the mint, but its dead-tag
refusal keeps R98's long voice ("its filter needs the tag #x, which doesn't exist right now — recreate it
(Settings → Tags) first") while the mint's hover/refusal says her shorter "Its rule needs #x, which no longer
exists." One authority, two sentences for one blocker. Not this run's mandate (her #217 words were the mint's);
worth naming in the VX-216 hand-off beside the chip's third voice.

### F-10 · NIT (conservative-direction corner; traced) · `Sources/VariorumCore/Domain/GatheringMint.swift:281–291, 343–348`

`keepsNegations` weighs only TOP-LEVEL NOT conjuncts, so an atoms-only any-of can pick an option that a LATER
deferred group's NOT options forbid, and the deferred group then has no positive option left:
`(#a OR #c) ∧ (¬#a ∨ ¬#b) ∧ #b` → the group takes #a, `#b` is taken, the deferred group fails → `.blocked
(.unreachableTerm)`, though `{#c, #b}` meets the rule. Never a mis-enable (the final check only greys), and only
the rule editor can author it — so a NIT; a planner pin expecting `.plan([c, b])` would be red today if the
orchestrator wants the corner closed (e.g. let `keepsNegations` also require every deferred group to stay
satisfiable).

### F-11 · NIT (an unrecorded twin of P-VX381-U2-5, for her bundle) · `Operations+Tag.swift:220–230` × `Operations+Container.swift:705–707`

P-VX381-U2-5 records one order (the note dies AFTER the tag delete → the application stays dead on undo). The
other order is also lossy and order-dependent: note N wearing #x is deleted (its `post_tag` dies on N's stamp S1)
→ Delete Tag #x (stamp S2; the trigger skips the already-dead application) → Put back N while #x is dead
(`restoreContainer` revives applications on S1 only `AND tag_id IN (live tags)` — skipped) → Undo Delete Tag
(revives applications on S2 only — skipped). N has permanently lost #x; doing the undo BEFORE the Put back keeps
it. Same exact-stamp discipline, same class as U2-5 — one line in the bundle so her ratification covers both
orders.

## Severity-ranked index

| # | Severity | One line |
|---|---|---|
| F-2 | BLOCKER | Undo Delete Tag revives a child with its pre-rename path under a renamed parent — stale materialized path, broken subtree matching, a later parent delete leaves a live tag under a dead parent (probed). |
| F-1 | BLOCKER (P1) | The revival's `IN (SELECT id FROM container/block …)` guards scan the whole table per revived tag — corpus-scaled cost (plan + timing measured). |
| F-3 | MAJOR | The sustained P-VX381-U2-3 refusal reaches her as `Undo failed: Refused: duplicateTagPath(path: "work")` on the Mac (raw enum; the phone prints it bare) — no road named. |
| F-4 | MINOR | Hide-owned twin of VX-241: collecting an owned note into a hide-owned gathering says "shows it now" while the assembly hides it (probed; pre-existing class). |
| F-5 | MINOR | Ruled (R-VX381-A4): the phone's ★ collect now stars past the cap and says "Added by tagging  — …"; VM-21 carries it with no priority. |
| F-6 | NIT | Unrecorded PROVISIONAL: a `★ OR #a` rule makes the collect STAR an existing note rather than tag it. |
| F-7 | NIT | `taggedWhileArchived`'s empty arm builds "Tagged  — …" where the live arm says "Added to the gathering." (unreachable today). |
| F-8 | NIT | `GatheringNoteDoorCopy.cannot` is now the identity; `divergeTarget`'s nil-case doc is vacuous after `memberBooks`. |
| F-9 | NIT | One planner, two dead-tag sentences (the collect keeps R98's long voice) — route to VX-216. |
| F-10 | NIT | Planner greys `(#a ∨ #c) ∧ (¬#a ∨ ¬#b) ∧ #b` though `{#c, #b}` meets it (conservative direction; probed). |
| F-11 | NIT | P-VX381-U2-5's other order (note deleted before the tag delete, put back while it's dead) also loses the tag. |

Probe note: F-2, F-4, F-6 and F-10 were confirmed by throwaway tests in a SCRATCH COPY of the branch (outside the
repo); nothing in the worktree was edited but this record.

## Clean bill (checked and found solid)

- **Scope (the brief's first ask):** the diff touches NO editor seam (`CeremonySheetChrome.swift` is the ceremony
  sheets' SwiftUI footer under `Features/Editor/`, not `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/the read
  tier — one `.opacity` line removed), NO `Sources/VariorumCore/Sync/`, NO custody/Keychain code
  (`SettingsSceneContent` only chooses a face from `AppBootstrap.State`; `StoreLockView`/`LibraryMissingView`
  re-face through the style with zero lines changed), NO schema/migration, and no default's meaning. The
  opus-reviewer cast is correct for this round.
- **The planner never mis-enables a door** (VX-250 (3) + VX-249): every plan ends in a full `freshNoteMatches`
  pass that mirrors `ruleSQL` term for term (three-valued legacy NULLs, `"1"`/`"0"` for empty all-of/any-of,
  wing-scoped liveness, subtree `tagCovers` fed live paths), and both ops keep the in-transaction `matchesRule`
  belt. Fresh-note plans are unchanged by U2's starting-state inputs (every default describes a note that wears
  nothing; `alreadyMet` is false for it).
- **Her #217 words land byte-for-byte**: the four mint receipts, the three hovers + the purged-tag fallback
  (`GatheringMint.swift` `reason`, `ShelfViewModel.swift` `shownByMint`), "Opening your library…" (U+2026) —
  each pinned (`herShorterHoversLandVerbatim`, `herShorterMintReceiptsLandVerbatim`, the Settings pins).
- **VX-249's star write** goes through the ONE star write (`writeStar`, cap-exempt per her ruling, intake heard
  — `theCollectsStarIsAnApplyingActALivingBookHears`), inside the op's one transaction, and a refused belt
  unwinds tags AND star (`aRefusedCollectUnwindsTheStarAndTheTags`, the setting value compared). `starred` is
  true only when the plan took the star (never for an already-starred note).
- **VX-241's fact is read in the op's transaction** (`reading.archivedAt` from `liveReading` inside the write), and
  both Mac doors decide from it.
- **VX-247's registration**: ONE entry inside the op (every door rides it; no MCP tag-delete tool exists — grep of
  `Sources/VariorumMCP` clean), exact-stamp inverse, exact-row redo with its own stamp handed back, quiet halves
  retire (`UndoStack.undoReporting`/`redoReporting` semantics read), a thrown inverse rolls back its whole write
  and keeps the entry (LIFO doctrine). The trigger copies `NEW.deleted_at` verbatim (`Triggers.swift:88–98`), so
  the exact-stamp read is sound. Applications revive onto live targets only and never beside a live twin.
  The canon carries (AppSpec §9's undo list, the VX-246 sweep-table row) are named in the record's "CLOSEOUT
  CARRIES" — owed at closeout, not missing now.
- **VX-111**: `readingsContaining` is books (member rows, archived books kept) + showing gatherings; the trigger now
  counts and targets `kind == .book` only — the masthead's rule; the three trigger pins cover silent/2-book/1-book.
- **VX-194**: the style reads `@Environment(\.isEnabled)` in a body View (so a container's `.disabled` reaches
  it), draws a tokens-only quiet face, keeps the role's weight; my own sweep of the calm-button files' `.disabled`
  sites found no second local dimming one-off beyond the folded ceremony confirm (`.disabled(!canConfirm)` is
  present, so the environment carries the face).
- **Targeted core suites green on the branch tip** (run by me, headless): TagDeleteUndoTests ·
  CollectSetsTheStarTests · CollectPlannerStartingStateTests · GatheringMint (both suites) · SmartCollectTests ·
  StarContextTests · InvariantSweep · RuleWingScoping — "68 tests in 9 suites passed". The Mac batch claims were
  read against the pins' source, not re-run (a Mac run needs a stage GO).
