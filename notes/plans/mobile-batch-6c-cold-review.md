# Cold review — batch 6c, the Two-rooms IA (`bfd0df5..51101ba`)

*Cold Opus reviewer, zero implementation context, 2026-08-31. It ran the
full mobile suite on its own armed simulator — `Test run with 607 tests in
94 suites passed … with 2 known issues`, exactly the record's claim, test
arithmetic exact (+15 = 11+2+1+1) — verified all three red-on-old reverts
line-consistent, and traced the record's flagged D5 deviation at FOUR links
before endorsing it. **Counts: 0 BLOCKER · 0 MAJOR · 4 MINOR · 6 NIT.***

## Findings (landed in full — the compressed-summary rule)

**m1 [MINOR] · `MobileVersions.swift:216-227` · READ-ONLY.**
`MobileVersionsModel.rowMeta` composes as shared `VersionsPath.rowMeta(item)`
MINUS ELEMENT 0, assuming element 0 is always the date — positional
coupling to an array whose contract promises no order, whose own doc names
a live future that will edit it (13w's automated rotation renders there),
and which no pin covers (`rowTitle` is pinned; `rowMeta` is not). A reorder
or new leading piece silently drops the wrong element with zero signal —
the drift class arriving through composition instead of copying. *Fix:*
pin the composed string, and/or compose from named pieces rather than
counting to one.

**m2 [MINOR] · `MobileNoteActions.swift:180,195` + the record §3 item 5 +
the pin name · READ-ONLY.** The batch invented THREE Versions sentences,
not one: beside the recorded ⌘⇧S-empty-line re-voice, the note ⋯ rows
carry invented detail prose — and one ("saves this whole note as it is
right now") is a near-verbatim rewrite of a clause inside
`VersionsPath.empty`, the same sentence living twice, which
`VersionsCopy.swift`'s own header forbids. The pin's name and the record
both say "the ONE gap". *Fix:* de-duplicate the near-verbatim detail
(genuinely phone-voice it; a shared `saveDetail` home is FENCED and goes
to the next Shared-touching batch's list), extend the pin to cover all
phone-voiced Versions strings, and correct the record's count.

**m3 [MINOR] · `MobileVersions.swift:97-105` · READ-ONLY.** The Versions
listing is the one new phone listing with NO window and NO truncation
marker — every sibling takes `window + 1` + a visible marker, and
`Queries.noteVersions` already carries `limit: Int? = nil`. True-today
("versions are hand-saved") is exactly what 13w un-makes. *Fix:* pass
`limit: window + 1`, reuse `TrashListing.windowed`, add the marker string
beside the Archive room's.

**m4 [MINOR] · `MobileNoteActions.swift:188-191` + record §1 D4 ·
READ-ONLY (risk half SPECULATIVE).** The `dismiss()`-then-push road's
comment claims a "proven road on this app" — the cited precedent is
DEBUG-only (`onOpenTutorialBook`), unpinned even there, and a different
shape (state-flag flip + append in one scope, not environment-dismiss then
a call up the tree). No actual failure traced; the provenness CLAIM is
falsifiable and false. *Fix:* correct the comment and record; and either
drive the composed road once on a mounted `MobileShellView` or invert the
order to match the precedent's shape.

**n5 [NIT]** · `MobileArchiveModel.swift:98-100` vs
`MobileTrashModel.swift:243-245` — a second byte-identical `refusal(_:)`
forward (the RULE stays shared in `RecoveryActs`; two call sites must now
change together, and `DeletionRefusal.Act` has no `.unarchive` arm, so the
Archive's unarchive refusals speak the put-back sentence — inherited).
**n6 [NIT]** · `MobileVersions.swift:109-125` — a failed moment read
leaves the reader open, empty, with all three live verbs; `closeReader()`
in the catch. **n7 [NIT]** · `theCombinedSurfacesNameIsGoneFromThePhone`
claims corpus-wide, asserts one surface (the wide claim IS true —
grep-verified zero phone call sites); narrow the doc or widen the pin.
**n8 [NIT]** · the new Archive room is the one surface where a born-
archived VERSION could newly leak into a phone listing, and no phone pin
holds the fence (the reviewer verified it holds — core's
`excludingVersionHistory: true` default + nine core pins); one line in
`theTwoRoomsCarryOnlyTheirOwnPromises`. **n9 [NIT]** · both rooms'
truncation-marker strings are unpinned (inherited gap, now on a new
surface). **n10 [NIT]** · the rooms' "Open note" doors are routed but
never driven — the one door on the new surfaces no pin activates, in the
round that shipped four dead-door classes.

## Clean bill (headlines; the full text is in the session record)

D5's declined flip CORRECT at four links (the region is take-only;
`TrashScope.listedKinds` cannot widen past its literal; the Mac's own arm
names the TRAY; the precondition pin is real and falsifiable) · the split
lost NO guard (the Trash diff is pure deletion of the archived half;
`MobileArchiveModel` has no purge road AT ALL — in-trash-only is
structural; the nowhere-else pin covers the new room over a populated
screen) · `TrashScope` untouched, pinned at four surfaces · P1 rides both
rooms (window+1 through the core wrapper, `TrashListing.windowed`) · one
door declaration, two renderers, driven end-to-end with different
destinations proven · the retired route leaves nothing orphaned
(compile-proven) · `RecoveryCopy.surfaceName` zero phone call sites,
`Shared/` byte-untouched · the fence held everywhere · the Versions verbs
match her ratified shapes, DRIVEN not asserted (real alert with
`presenting:`; asking-is-not-doing proven; Promote no-confirm proven
against a surface that can present; Delete lands a version row in the
Trash with `purge_intent == 0`) · the 13u2 item-15 fence honoured · restore
flush-first through the ONE per-post coordinator · the two-model split is
a face split, not a forked brain (rules stay shared; the archived listing
MOVED, not copied) · ledger updates honest, D5's exception in the cell.

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL TEN ACCEPTED, ZERO DISPUTES.** No BLOCKER/MAJOR at round 1 ⇒ the
unit closes after ONE fix wave (the batch-1 economics: NITs and MINORs are
fixed without a further round); the orchestrator verifies the wave's diff.

**ONE Opus fix session, the ten items, adjudicated shapes:**

1. **m1**: compose `rowMeta` from NAMED pieces if the shared file exposes
   them individually (READ it — it is fenced for edits); if it does not,
   keep the composition but PIN the composed string and leave a comment
   naming the coupling and the 13w future. Either way the drift now has a
   signal.
2. **m2**: genuinely phone-voice the save row's detail (no near-verbatim
   rewrite of a shared clause), extend the pin to enumerate ALL
   phone-voiced Versions strings (rename it honestly), correct the record
   §3's "one gap" count, and add `VersionsPath.saveDetail` to the
   next-Shared-touching-batch list in the record.
3. **m3**: `limit: window + 1` + `TrashListing.windowed` + a visible
   truncation marker, the Archive room's shape exactly; pin the marker
   (folds n9's Versions-adjacent half in).
4. **m4**: correct the comment and the record sentence (mandatory), and
   drive the composed dismiss-then-push once on a mounted
   `MobileShellView` if the harness reaches it; if it cannot, invert the
   order to the precedent's shape and say so.
5. **n5**: inline both rooms' one-liner forwards to direct
   `DeletionRefusal.words(_:act:)` calls at their use sites, with a
   comment at the Act enum's phone callers noting the missing `.unarchive`
   arm is a FENCED (`Shared/`) addition for the next Shared-touching
   batch.
6. **n6**: `closeReader()` in the catch; pin it (a refusal lands on the
   listing, never an empty reader with live verbs).
7. **n7**: narrow the pin's doc comment to the surface it drives; keep the
   grep truth in the comment.
8. **n8**: the one-line version-fence assertion in
   `theTwoRoomsCarryOnlyTheirOwnPromises` (save a moment, assert it does
   not row in the Archive room).
9. **n9**: pin BOTH rooms' truncation markers (drive past the window on a
   seeded set, assert the marker renders).
10. **n10**: drive each room's "Open note" door once on the real mounted
    surface, asserting the shell receives the push.

Environment and rules: exactly the standing fix-brief block (own armed
simulator, private DerivedData, full mobile suite at the end — baseline
607/94 + 2 known issues — quoted line, `Package.resolved` never swept,
fence verified empty before the pathspec-limited commit, no pushes).
Append a FIX WAVE RESULTS section to THIS file before the final message.
