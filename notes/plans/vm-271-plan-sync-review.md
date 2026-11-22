# VM-271 — sync-focused cold review of the phone editor core plan (draft v2)

**Reviewed:** `notes/plans/vm-271-phone-editor-core.md` at `cdff1428c` (branch `vx-1033-nov-22-sitting`), read whole,
then §5.3, §8, §10.1, §11 and §12 again.
**Tested against:** `main` at `b23550bc8` (the worktree differs from `main` only in `notes/`): `notes/SyncSpec.md` whole;
`Sources/VariorumCore/Sync/Merge.swift`, `Repairs.swift`, `SyncEngine.swift` (push and reject), `PullStage.swift`;
`Sources/VariorumCore/Operations/` (`+Variant`, `+Structural`, `+BlockArchive`, `+Placement`, `+Sync`, `+TakeEdits`,
`+LineageBringBack`, `+MCPEdits`, `+NoteVersions`, `+Container`); `Queries/PostRender.swift`, `TakesQueries.swift`,
`Lineage.swift`; `App/Variorum/Shared/AutosaveCoordinator.swift`, `AppSession.swift`, `SyncSession.swift`,
`AppServices.swift`, `OperationsRunner.swift`, `EditorBrain/CrossBlockCompound.swift`, `EditorBrain/EditorProjectionEngine.swift`;
the Mac's `EditorViewModel.swift` and `EditorSurfaceController.swift` (deliveries and the seam merge); the phone's
`MobileEditorViewModel.swift`; the worktree's `phone-sync-lag-report.md`, `phone-editor-inventory.md`,
`phone-editor-audit.md`; the first review `vm-271-plan-cold-review-1.md`; the existing convergence suites
(`SyncConvergenceTests`, `StructuralSessionSyncTests`).
**Posture:** read-only. Nothing built, run or installed; no harness run. "Inference" marks my own reasoning where I did
not read a line that settles it. Examples use neutral block names: X is the block she is typing in, P and N its
neighbours, M a merged successor, B and C divide successors, T1 and T2 takes. No note text from anyone.

---

## 0. The short answer to her question

> "saving checking it's still in this note - what's the exact issue here? what is still in this note? the block?"

**Yes: the block.** Her words go into a take (a `variant` row). The take belongs to a block. The block is in the note
because one `container_block` row (its placement) points at the note. Five acts on another device take that placement
away **without writing the take's row at all**: a merge, a keep-on-top divide of a block with takes, an archive, a
move to another note, and a delete (which also tombstones the take). Sync only notices a race when two devices write
the **same row** (SyncSpec §6; `Merge.swift` works one row at a time). So when the Mac merges X while she types in X on
the phone, the two devices never collide: her text row and the Mac's placement rows are different rows, both are
accepted, and the result converges cleanly to a note that shows the Mac's older copy of the paragraph, with her newer
words sitting in a block that is no longer in the note (lineage). Nothing tells anyone. The engine has no rule for it
(`Repairs.swift:486-489`: "a live unplaced block is a LEGAL state — released to lineage").

**The plan's check (§11.3) answers the wrong half of that race.** It refuses a save only when the phone *already knows*
the block left the note. Most of the time it does not know yet: the phone hears the Mac's change at its next sync round,
seconds to minutes later, or at its next open (the lag report, §1c–§1d, §5 cause 4). By then her words have been saved
and often pushed. Every save made before the phone hears passes the check and lands in lineage, in both orders of
arrival at the server. The check also turns a harmless case (a block moved to another note, where her words would
simply follow it) into a duplicate.

**The fix belongs at the moment the phone hears, not at the save:** when a delivery takes a region's block out of the
note, the editor compares what it saved into that block with what the note now shows, and if her words are not there,
it brings them back into the note (§4 below says how). That needs no operation change and no `Sync/` line. The Mac has
the same hole today, and this plan makes it more frequent on the Mac, because Return and backspace on the phone become
merges and divides (§9).

There is a second, independent sync hole the plan opens by itself: it writes the page from what it believes the library
holds, then sends structural operations that re-read the library's *current* rows. If a sync pull lands in between, the
operation acts on text the page never showed, the plan adopts the operation's result as the save base, and her next
keystroke overwrites the other device's words with no rescue (§5, finding B1). The MCP door already guards exactly this
race; the phone must do the same.

---

## 1. The facts every cell below rests on

**F1. What each act writes, row by row.** (Code read; `+Structural`, `+BlockArchive`, `+Placement`, `+Deletion`,
`+Variant`.)

| Act | `variant` rows of X | `container_block` of X | `block` X | New rows |
|---|---|---|---|---|
| `autosave(X's take)` | **updates** text | — | — | — ; also writes the **container** row (touch, churn: `registerTextChange`, `+Variant.swift:805-829`) |
| `divide(X)` single take | **updates** X's take to the first half (`:228-231`) | — | — | C: block, variant, placement, edge, comment copies; container touched |
| `extract(X)` | **updates** X's take to the remainder (`:118-121`) | — | — | the extracted block, edge, comments |
| `divideW` / keep-on-top on fanned X | **untouched** (A preserved whole) | **tombstoned** (`:423-426`) | updated (`last_container_id`) | B, C fans, edges, comments |
| `merge(P, X)` (door or delete keystroke) | **untouched** | **tombstoned**, both sides (`:875-884`) | updated, both | M: one take, edges to both, comments |
| `archiveBlock(X)` | untouched | **tombstoned** (`+BlockArchive.swift:78-83`) | `archived_at` set | — |
| `moveBlock(X → other note)` | untouched | **updated in place** (`container_id`, position) | — | — |
| `reorder(X)` | untouched | position updated | — | — |
| `deleteBlock(X)` | **tombstoned** by the cascade | tombstoned | tombstoned | — |
| `chooseVariant(X, T2)` | untouched | `chosen_variant_id` updated | — | — |
| `lockVariant(T1)` | `locked` updated (the row is pushed whole) | — | — | — |
| `lockPost` (seal) | — | — | — | the container row `locked`; quiet commits of dirty takes |
| new take on X | — | — | — | a variant row |

**F2. Where the two devices meet, and what happens there.** A pushed row whose base `sync_version` is stale is
rejected, and the client merges against the server row (`SyncEngine.swift:322-386`). The merge (`Merge.swift:26-137`):
- **text vs text on the same take** → the server's text wins the row, the other text becomes a `'conflict'` take (S5);
- **a take's text vs that take's tombstone** → the tombstone wins; the text is rescued as a take while the block is
  live, or **rides the tombstoned row into the Trash** when the block is dead (`:58-127`);
- **metadata on the same row** (a lock, a seal, a title, a segmentation setting, `chosen_variant_id`) →
  **server-version-wins, local intent dropped** (`:33`; pinned as "worst case a lost rename",
  `SyncConvergenceTests.swift:54-69`).

So: acts in the first three rows of F1's table meet her typing at the take's row and produce S5's conflict take.
**Acts that release (`divideW`, `merge`, `archiveBlock`) or move never meet her typing at all.** There is no repair
for "a take's text changed after its block's placement was released" (`Repairs.swift:486-494`: the orphan check for a
`variant` looks only at the block's liveness).

**F3. When the phone hears.** From the lag report (`notes/plans/vx-1033/phone-sync-lag-report.md`): no pull while the
app sits open and idle; while she types, one round about 3 s after the outbox count changes, then one per round's
duration (a round can take about a minute); one round on leaving, inside the iOS grant, which may not reach its push
(cause 4), so **her last phone edits are often still unpushed when she next edits the same note on the Mac.** The
"offline" case in this review is therefore the ordinary case, not an exotic one. The MCP door adds a second ordinary
case: an agent on the Mac can divide, merge, edit and lock takes (`Operations+MCPEdits.swift:352-439`,
`+MCPNoteEdits.swift`) while she types on the phone.

**F4. Between the editor's plan and its operation, a sync apply can land.** The runner serializes only runner bodies
(`OperationsRunner.swift`). The engine writes through the database writer in its own transactions. The plan's saver
flushes, then runs the operation (§11.1): two transactions. The compound's legs are separate transactions too
(`CrossBlockCompound.swift:514-516`, "the recorded ms-window sync-apply residual"). The MCP door states the same fact
and guards it: "Only a sync apply can land between the read and this transaction" (`+MCPEdits.swift:363-366`).

**F5. SyncSpec's acceptance of structural races rests on a premise this plan removes.** SyncSpec §7, "Documented
convergence behavior": two devices dividing one block converge to duplicated content, "Accepted: structural editing is
desktop-only by product design, making the race author-vs-herself-on-one-machine rare to impossible in practice."
SyncSpec §1 says the same of mobile's surface ("create entries, edit active text"). Under this plan Return is a divide
and backspace at a block's start is a merge or a delete, on the phone, at keystroke rate.

**F6. The existing convergence tests would pass on every hole below.** `StructuralSessionSyncTests` and
`SyncConvergenceTests` assert convergence (empty outboxes, byte-identical tables, identical rendered text). A note
whose paragraph's newest words sit in a released block has converged perfectly. The bar this design needs is
different: **every word either device typed is in the note, in a take of a placed block, in the Trash, or said.**

---

## 2. The two-device matrix

The phone has the note open in the new editor, keyboard up. "Order A" means the Mac's change reached the server first;
"Order B" means the phone's did. "Phone offline" means the phone reconnects after the Mac's change: its pull lands the
Mac's rows first and its push follows (A3's round order), so it behaves as Order A with all her pre-reconnect saves
landed locally and unpushed. "Interleaved" means both rounds' pulls ran before either push (Mac pull, phone pull, Mac
push, phone push): each device then sees the other's rows only after its own were accepted.

### 2.1 The cells that are fine (grouped)

- **Phone typing × Mac edits other blocks, reorders other blocks, adds or deletes other blocks**: different rows; the
  page updates other regions (§12.2). Fine, subject to §6's mechanics.
- **Phone typing × Mac adds a take to X, or deletes a take of X she is not shown**: a new or tombstoned row she never
  wrote. The map's fan fact changes; her page text is untouched. Fine (but see finding M2 for her *next* backspace).
- **Phone typing × Mac deletes the note**: the container tombstone cascades on the phone over her dirty take; the take's
  own tombstone then arrives and her text rides it into the Trash (`Merge.swift:121-127`). The phone drops the keyboard
  (`MobileEditorViewModel.swift:962-966`). Her landed words come back with Put back. Only the unsaved half-second is at
  risk (finding m6).
- **Phone typing × Mac restores X**: X was not on her page (it was deleted), so nothing races; it appears as a region.
- **Phone deletes X (carve, a selection, the menu) × Mac types in X**: the Mac's text loses to the tombstone and rides
  into the Trash in both orders (`Merge.swift:170-209` then the overlay). Recoverable. The Mac's page is the Mac's
  problem (§9).
- **Phone delete × Mac restore of the same block**: tombstone wins in both orders (local tombstone overlays a live
  server row; a live local row accepts a tombstoned server row). Recoverable from the Trash.
- **Phone idle mint of the open end × anything on the Mac except a seal or a note delete**: the open end exists only on
  the phone; the mint is a fresh block at `.end`, ordered by `(position, id)` against any block the Mac appended. The
  page keeps the open end last (§5.2) and the mint lands after whatever the delivery inserted. Fine.
- **Any act × Mac undo**: an undo emits ordinary operations of the same row shapes as the act it inverts (a merge's undo
  releases M and revives the sources' placements; a divide's undo restores A's text and tombstones C). Each falls into
  the row of the matrix its rows belong to. One notable consequence: the Mac undoing its own merge **revives X's
  placement and brings her stranded words back into view** — and if the phone has already rescued them, the note then
  shows them twice (visible, nothing lost).

### 2.2 The cells that need words

| # | Phone | Mac | Rows and convergence | Phone's page under the plan | Where her words end | Verdict |
|---|---|---|---|---|---|---|
| 1 | typing in X | edits X's text | Order A: the phone's flush-before-round lands her typing, the pull meets her dirty row, server text wins, **her text becomes a `'conflict'` take** on X. Order B: the Mac's push is rejected, **the Mac's text becomes the take**. | A delivery shows X's text changed. Region with nothing unsaved: rewritten to the library's text, fan badge appears. Region with unsaved typing: kept (§12.2). | A take on X, or the row. | **Safe only if** the map never advances `stored` for a region with unsaved typing (finding M1c). If a delivery refreshes `stored` while her page text is kept, her next save's `expectedText` equals the row and her text overwrites the Mac's words with no card. |
| 2 | typing in X | divides X (one take) | Both orders: same row (X's take), S5. Order A: X's take = first half, her whole paragraph a conflict take, C = second half. Order B: X's take = her whole paragraph, the Mac's first half a conflict take, C = second half. | C is inserted after X. With unsaved typing, X keeps her whole paragraph and C repeats its second half on the page; her next save rescues again (a third take). | A take on X or X's row. | No loss. **The second half is duplicated** (inside X's take or on the page), plus one or two conflict takes. The documented S5 cost; it becomes frequent once she divides on the phone too. |
| 3 | typing in X | keep-on-top divide of fanned X | No common row. X's placement released; B and C hold the halves of the Mac's copy. Her text lands on X's take, **in lineage**, both orders. | X's region removed, B and C inserted. Unsaved typing: X kept (duplicate of B+C on the page), next save refused by §11.3, new block. | Pre-delivery saves: **lineage, silently.** Post-delivery: a new block beside B and C. | **Loss from the note** when she had nothing unsaved at the delivery; duplicate otherwise. Finding B2. |
| 4 | typing in X | merges X with P or N (door or delete keystroke, or the Mac's compound) | No common row. Both placements released; M = the Mac's copy of P joined to the Mac's copy of X. Her text lands on X's take in lineage, **all three orders** (A, B, interleaved). | X and its neighbour removed, M inserted. Unsaved typing: X kept, M repeats X's older text; next save refused, new block. | Same as 3. | **Same as 3.** This is the cell she asked about. Finding B2. |
| 5 | typing in X | extracts from X | Same row (X's take is rewritten to the remainder), S5. Her whole text, extracted span included, becomes a take (Order A) or keeps the row (Order B). | The extracted block is inserted; with unsaved typing the span shows twice. | A take on X or the row. | No loss; the span is duplicated. Same class as 2. |
| 6 | typing in X | deletes X | Her text rides into the Trash with X (both orders). | Region removed; with unsaved typing, §11.4 makes a new block. | Trash (pre-delivery); a new block (post-delivery). | No loss, but **the rescue re-creates what the Mac deleted**, which is not the canon's answer (SyncSpec §6: tombstone wins, the text rides into the Trash). Hers to decide (D3). |
| 7 | typing in X | "restores a version" of the note (`restoreNoteVersion`) | The outgoing blocks take the **Delete Now road**: tombstoned plus a purge intent (`+NoteVersions.swift:122-131`). Her unpushed text rides X's tombstone; the intent's read fence hides it from the Trash; the janitor purges it at the horizon. The version of now the Mac saved first does not contain her unpushed words. | Region removed. | **Lost**, as far as I can trace (inference: I did not run the purge horizon against a ride). | Pre-existing hole, not the plan's; the delivery-time check (§4) closes it for a live editor. Finding M8. |
| 8 | typing in X | archives X | No common row. Placement released, `archived_at` stamped. Her text lands in the archived block. | Region removed; unsaved typing: new block (§11.4). | Pre-delivery: the tray's "Deleted & archived", recoverable by Put back. | No loss; a duplicate if the rescue fires. |
| 9 | typing in X | moves X to another note | No common row. Her text lands in X, now in the other note (and her autosave touches *that* note's container). | Region removed; unsaved typing: §11.3 refuses ("not placed in that note"), new block here. | Pre-delivery: in X, in the other note, visible there. Post-delivery: **a duplicate** in this note. | The plan's check manufactures a duplicate where nothing was at risk. Hers to decide (D3); lean: her words follow the block and the line says where it went. |
| 10 | typing in X | reorders X | Different rows. | §12.2 must move the region. It does not say a moved region with unsaved typing carries its **page** text, or what "lower, rebuild, raise" rebuilds from. | On the page, if moved correctly. | Underspecified; finding M1b. |
| 11 | typing in T1 of X | chooses T2 on X | Different rows (`container_block` vs the take). Her saves land in T1, a take of a placed block. | The delivery shows X rendering T2. The plan does not say whether the region rebinds (dropping her unsaved text from view) or keeps T1 as a peek. | T1, a take. | No loss; behaviour undefined (finding m3). |
| 12 | typing in T1 | deletes T1 (re-points the slot to T2 first, as `deleteVariant` requires) | Order A: her dirty T1 meets T1's tombstone; the block is live, so **her text becomes a conflict take** (`Merge.swift:180-181`). Order B: the Mac's tombstone push is rejected; the Mac rescues her text as a conflict take. | Region rebinds to T2 (if it does). Unsaved typing: her save into dead T1 is refused (`variantNotFound`); §11.4 has no row for this cause. | A take on X. | No loss at the store; the plan's rescue table needs a row: a **take on the same block**, not a new block (finding M3). |
| 13 | typing in X | locks X's take | Same row. Order A: her dirty row meets the locked server row: server text and the lock win, **her text becomes a conflict take** (unlocked). Order B: the Mac's push is rejected; server-wins drops the **lock** (metadata intent is not re-applied), and the Mac's pre-edit text becomes a spurious conflict take. | Order A: region read-only, fan badge. Unsaved typing: refused (`lockedVariant`), §11.4 makes a new **block**. | A take on X. | No loss. The plan's rescue contradicts the model ("lock a variant … edit by branching", OverallModel §3): the rescue should be a branch take on X (M3). Order B's lost lock is pre-existing (m1). |
| 14 | typing in X | seals the note | The seal is a container-row write; every phone autosave also writes the container row (F1). Order A: the phone's container row is dirty, server-wins lands the seal; **her take rows still push and are accepted** (sync does not enforce a seal). Order B: the Mac's seal push is rejected and **the seal is dropped** (server-wins). | Order A: post-delivery saves refused (`lockedPost`); the words stay with Copy (§11.4). Order B: nothing on the phone. | Order A: pre-delivery words are in the sealed note; post-delivery words only on the page. | No loss of saved words. The lost seal in Order B is pre-existing (m1). Post-delivery words die at leaving unless copied (m6, D7). |
| 15 | Return (divide X) | edits X's text, the pull lands **between the phone's plan and its operation** | The phone's `divide` cuts the **current** row (the Mac's text) at the page's offset; no text precondition (`+Structural.swift:206-231`). §10.1 sets both regions' `stored` from the result. | The page shows the old text cut at the old place; `stored` holds the Mac's text cut at that offset; deliveries compare against `stored` and see nothing to change. | Her next save in either half writes old-based text with `expectedText` = the row. | **The Mac's words are overwritten, silently.** Finding B1. |
| 16 | Return (divide X) | edits X's text, Orders A and B at the server | Same row, S5 (as cell 2 with the roles swapped). | The halves; a fan badge on X. | X's row or a take. | No loss; duplicate second half. |
| 17 | Return in fanned X (keep-on-top) | edits X's take, after the phone's act | No common row: the Mac's text lands on X, released by the phone. | — | — | **The Mac's words strand in lineage** (the mirror of cell 4). Finding M7. |
| 18 | Return in fanned X | adds a take to X, landed before the phone's act | The phone composes keep-on-top from the map's fan; the new take is not among the cuts, stays on A, A is released. | B and C as planned. | — | **The Mac's new take strands in lineage, silently.** The MCP door guards this exact case (fan membership re-checked in the transaction). Finding M2. |
| 19 | backspace-join of X into P | adds a take to X (or to P), landed before the phone's act | `merge(P, X, .deleteKeystroke)` does not check fans; it copies the rendered takes and releases both blocks. The Mac refuses this join when either side has takes, **reading the fan from the store** at run time (`EditorSurfaceController.swift:2470-2478, 2522-2534`: "never `model.slots`"). The plan reads it from the map. | The joined page; no refusal (the operation does not refuse). | — | **The Mac's take strands in lineage, silently.** Finding M2. |
| 20 | backspace-join of X into P | edits P's or X's text, landed before the phone's act | `merge` joins the **current** texts; the page was written from the map's. §10.1 adopts the result as `stored`. | The page shows the old texts joined. | Her next save overwrites M with old-based text. | **The Mac's words are overwritten, silently.** Finding B1. |
| 21 | backspace-join of X into P | edits X, after the phone's act | No common row; the Mac's text lands on X in lineage. | — | — | **The Mac's words strand** (finding M7). |
| 22 | backspace-join (merge) | divides X | No common row in either order. M holds P + all of X; C (the Mac's second half) is placed after X's old position. | M and C. | — | No loss; **X's second half appears twice** (inside M and as C). The structure × structure duplication class SyncSpec §7 accepted on the premise F5 removes. |
| 23 | Return (divide X) | merges X with N | Order "Mac's merge applied before the phone's act": `divide` refuses (`blockNotPlaced`); §8.5 inverts the page; anything typed in the token regions has no binding (finding M4). Order B / interleaved: no common row; M = the Mac's X + N, C = the phone's second half of X: **duplicate**. | Inverted then rebuilt; or M and C. | Token-held keystrokes: undefined. | Duplicate, or undefined for keystrokes held behind the refused token. |
| 24 | cross-block compound | edits an **end** block | The compound compare-and-sets the two ends against the page (`CrossBlockCompound.swift:555-564`): refuses whole if the Mac's text landed first. If the Mac's text arrives after: the non-join road rewrote the end's take (S5, a take); the join road released it (the Mac's text strands, cell 21). | Refusal: §8.5 inverts. | — | Guarded at the ends. Join road strands the Mac's later words (M7). |
| 25 | cross-block compound | edits a **covered** block | Covered blocks are deleted without a compare (`:567-569`); the Mac's text rides into the Trash. | — | — | No loss (Trash). Accepted by the compound's own rule. |
| 26 | cross-block compound | inserts a block between the ends | `merge` refuses `blocksNotAdjacent`; the compound rolls back its legs (`UndoStack.withCompound`). A round between legs can push the intermediate state; it converges after the rollback's rows push. | §8.5 inverts. | — | Converges; a third device can briefly see the half-applied compound (m7). |
| 27 | a rescue (new block "at the region's place") | merged or deleted the region's neighbour | `newBlock(at: .after(P))` refuses when P has left the note; the plan names no fallback. | — | — | Finding m2. |
| 28 | idle mint or rescue | seals or deletes the note | `newBlock` refuses (`lockedPost`, `containerNotFound`). | Words kept with Copy. | Lost at leaving or at the lock. | Said, but lost (m6, D7). |

---

## 3. The placement check (§11.3), row by row

### 3.1 What "still in this note" should mean
Evaluated inside the save's transaction, in this order:
1. the take's row is live (`deleted_at IS NULL`) — already (`liveVariant`);
2. the take is active, not archived — already (`editableVariant`, `+Variant.swift:681-691`);
3. the take is not locked — already;
4. the block's row is live — **not checked today** (`autosave` reads block liveness only for the card guard, `:66-67`).
   In steady state the cascade makes a live take imply a live block, but the predicate should say it;
5. the block is not archived — implied by 6 (archive releases the placement);
6. **exactly one live `container_block` row for the block, whose `container_id` is this note** — the new part;
7. that note is live and not sealed — already (`ensurePlacementUnlocked`, `Operations.swift:178-182`).

Deliberately **not** part of it: "the take is the placement's chosen take". A peek saves into a shown take that is not
chosen (§12.4), and a chosen flip from another device (cell 11) leaves her take a legitimate take of a placed block.

### 3.2 What the plan's wording leaves open
- "Placed in that note" vs "placed anywhere": as written, a block moved to another note refuses and is duplicated
  (cell 9). If the intent is "never land where she cannot see it", a moved block's save landing in the other note is
  visible there; the line can say so.
- It does not say which surfaces carry the guard: the takes sheet's card editor and the open end's mint share the
  coordinator; the plan's per-entry note id would leave them unguarded or need the coordinator to stamp every entry.
- It does not say what happens to the refused entry in the coordinator (finding M5).
- It does not say what the parameter is called; the house idiom for an in-transaction precondition is
  `guardedBy: WriteGuard?` (`Operations.swift:110`), already on `commit`, `divide`, `divideW`, `merge`, `moveBlock`,
  `reorder`, `restoreBlock`, `deleteBlock`. A bespoke `noteID` parameter is a second idiom.

### 3.3 When the check passes locally but the server has already released the block
**It is the same silent landing, one round later.** The phone's save passes (its local placement is live), lands,
pushes, and is accepted (no other device wrote that row). The engine meets nothing: `Merge.swift` runs only on a
rejected or locally-dirty row of the same table and id; the pull's orphan check for a `variant` looks only at its block's
liveness (`Repairs.swift:490-494`); no post-apply repair inspects "text written to a released block". Both devices
converge on her words in lineage.

**Does the check need to run again at apply time?** Not in the engine; the engine cannot do it cleanly:
- At the phone's pull (Order A), the engine *could* see "a release is landing on a block whose take is dirty in my
  outbox" and record it. At the Mac's pull (Order B), it could see "a text change is landing on a block whose release is
  dirty in my outbox". That is exactly one meeting point per race in Orders A and B.
- **In the interleaved order there is no meeting point at all**: each device's own rows were already accepted when the
  other's arrived, so neither device sees anything dirty. A seq-based rule on converged bytes ("text seq after release
  seq") is deterministic on every device, but then every device detects it, so the rescue needs either one designated
  minter or a new dedupe repair for duplicate rescues — a SyncSpec §6/§7 extension, `Sync/`, the Fable class, and her
  ruling.

**What already exists that should carry it:** the editor itself. The map knows what it saved into each block (its
`stored` text), and the delivered projection already carries, for each placed block, the released blocks in its lineage
(`TakesProjection.unplacedOrigins`, `Lineage.swift:104-143`, keyed by the placed successor, with the edge's `origin_op`).
So when a delivery removes a region's block, the editor can name the successor (M for a merge, B and C for a divide,
none for a delete, archive or move) and check whether her saved words are in it. Only the device that wrote the words
does this, so there is exactly one rescuer per stranded edit, in every order, including the interleaved one. This is §4's
recommendation.

**The parameter then becomes optional.** Every save that the parameter would refuse lands either before the delivery
(caught by the delivery check) or between the pull's commit and the delivery reaching the map (also caught by it, since
those words are in `stored`). Without the parameter, the stranded write in that short window is an older copy of her own
words left in lineage, which is harmless. Deleted, locked and sealed saves already refuse today and need §11.4's rescue
either way.

**Is the parameter a SyncSpec §12 event?** No, confirmed. It adds no table or column, changes no synced column's
meaning, changes nothing the wire carries, and changes no outbox behaviour; a refused save writes nothing. It is an
operation-contract change (AppSpec §9's `autosave` entry), which is hers. The wire's own writes go through
`editTakeUnderInsurance`, not `autosave`, so the MCP door is unaffected (worth one line of confirmation against
`notes/MCPSpec.md` before building, per CLAUDE.md).

---

## 4. The rescue (§11.4)

### 4.1 "The region's place" once the block is gone
The plan does not define it. On the phone's page the region sat between two neighbours; after the delivery either may
also be gone (a merge removes both X and its partner). A `newBlock(at: .after(P))` refuses when P has left the note.
Needed: `.before(successor)` when the delivery names one, else `.after(the nearest surviving region above)`, else
`.before(the nearest below)`, else `.end`. Each resolves to a fractional position at the operation's time. Across
devices this is deterministic enough: only the writer rescues, so there is one mint, and its position converges by
`(position, id)` like any insert (SyncSpec §8).

### 4.2 Two rescuers, and rescues that duplicate
- **Two devices both rescue the same words:** only if both wrote to X and a third actor (an MCP agent, say) released it.
  Each rescues its own version, which are different texts. That is S5's outcome in a different shape, acceptable.
- **The phone rescues what the Mac's merge already contains:** when the Mac pulled her words before merging, M contains
  them. The plan's rescue (any unsaved typing ⇒ a new block) then puts a second copy beside M. The delivery check below
  catches this, because it looks inside M first.
- **A rescue block duplicates surviving text in most causes:** merge (M holds the older copy of the paragraph, the rescue
  holds the newer one), keep-on-top divide (B and C hold the older copy, split), move (the other note holds her earlier
  saves), delete (the Trash holds them), archive (the tray holds them). The plan's single rescue shape is a duplicate
  machine.
- **Lineage is not forever:** a released original is purged with its successor's family when the successor is later
  deleted and the purge runs (`+NoteVersions.swift:155-161` describes the mechanism). So "her words are still in
  lineage" is not a safe resting place, even when someone knows to look.

### 4.3 What the model's own machinery permits
- **A take on the successor holding her whole version of the successor's text** (I1: one block's text; I7: a
  whole-span alternative of the successor; I9: the cross-block relationship stays the existing `derived_from` edge).
  Permitted. The existing door is `resolveSyncConflict(successor's take, losingText:)` (`+Sync.swift:25-46`): same
  block, same parent, `'conflict'`, fan's end, never chosen, lands even under a seal.
- **A take on the successor holding only her paragraph** (not the whole successor's span): **not permitted** by I7's
  spirit. Choosing it would drop the partner's text from the page.
- **A lineage edge**: `bringBackFromLineage(.take(X's take), onto: M)` (`+LineageBringBack.swift:49-96`) already exists,
  but it copies X's text alone onto M, which is the partial-span take above. Not suitable as is. An edge from a rescue
  block back to X (origin `'manual'`) is permitted and would make the rescue visible in History.
- **A branch take on the same block** (locked take; deleted shown take): the model's own road ("edit by branching").

### 4.4 Recommendation: rebase first, rescue only when the rebase cannot be made
At the delivery that removes a region's block from the note (and at any save the library refuses):

| Cause the delivery shows | What to do | Rows |
|---|---|---|
| **Merged** (a successor M lists X among its `unplacedOrigins`, `originOp = 'merge'`) | If M's text contains, exactly once and at X's end of M, the text the library last showed for X (the map's last-delivered text for X), **write her version into M**: M's text with that segment replaced by her page text, via `autosave(M's take, expectedText: M's text)`. On the page, the break between the two regions loses its mark (the door join) or becomes the join character (the delete join). Nothing moves under her caret, no fan, no duplicate. If the segment is not found exactly once (the Mac edited X before merging), fall back to the next row. | one ordinary guarded autosave |
| Merged, not composable | A `'conflict'` take on M carrying her version when one can be composed some other way is not available, so: **a new block before M**, said, with an optional `derived_from` edge to X | `newBlock` (+ edge) |
| **Divided with takes** (B and C list X) | A new block before B, said. Composing across a cut is not reliable. Rare: it needs a block with takes divided on the Mac while she types in it | `newBlock` |
| **Divided, one take** (X stays placed) | Nothing new: S5 already gave a conflict take on X | — |
| **Deleted** | Hers (D3). The canon's answer is that the delete wins and her words ride into the Trash; say so with Put back. The plan's answer re-creates the paragraph | — or `newBlock` |
| **Archived** | The tray holds her pre-delivery words; same choice as delete | — or `newBlock` |
| **Moved to another note** | Let her words follow the block; say where it went. No refusal, no duplicate | — |
| **Locked take** | A branch take on X with her text (`branchVariant`, then an autosave into the branch, in one runner turn) | two ops |
| **Shown take deleted, block still placed** | A take on X with her text (`newBlankVariant` then an autosave, or a small shared composite) | two ops |
| **Note sealed or deleted** | Words kept on the page, Copy offered, and the line says they are lost at leaving (D7) | — |

Costs: one pure function in the shared brain (`StrandedWords.decide(lastDelivered:, stored:, pageText:, successors:)`),
one more fact per region in the map (the last text a delivery showed for it, beside `stored` and `settled`), and a
delivery check bounded by the regions the delivery removed (P1). It needs no operation change and no `Sync/` line.
The successor's rows can arrive one batch after the release (a push split across chunks): when a removed block has no
identifiable successor yet, the check waits for the next delivery before choosing "new block" (m5).

**A backstop for the editor that is not alive to see the delivery** (the app killed after pushing, the lock tearing the
screen down before the pull's delivery reaches it, or a fresh open that builds the map after the pull): a store-level
read at note open, "released blocks of this note whose take's text appears in no placed successor", shown as a lineage
hint rather than an automatic rescue, so two devices never both rescue. Queries only.

---

## 5. Tokens and operations in flight versus a sync apply

### 5.1 What each operation checks inside its transaction
| Operation | Checks in its transaction | Does **not** check |
|---|---|---|
| `divide(X, cut:)` | X live and placed; note not sealed; exactly one active take; take active and unlocked; the cut gives two non-empty halves | **the text the cut was planned on** (`+Structural.swift:206-231`). `guardedBy` exists (`:185-190`) |
| `divideW` / keep-on-top | X placed; each named take live, active, of X; cuts valid | the fan's membership (a take added since is unmarked and stays on released A); the texts. `guardedBy` exists |
| `merge(P, X, …)` | both placed; note not sealed; X immediately after P | **fans** (copies the rendered takes, releases the rest); **texts** (joins whatever the rows hold). `guardedBy` exists (`:850-856`) |
| `deleteBlock(.emptyWithNothingUnshown(variantID:))` | one live active unlocked empty take, no comments, unsealed — re-read inside the tombstone's transaction | — (sound) |
| `deleteBlock(.none)` | live, unsealed | the text (a remote edit rides into the Trash — the canon's answer) |
| `CrossBlockCompound.apply` | the two ends' texts (no-op `editTakesAtomically` with `expectedText`, `:555-564`); fans read from the store before the compound (`:544-551`); adjacency inside `merge` | covered blocks' texts; atomicity across its legs (separate transactions, `:514-516`) |
| `newBlock(at:)` | note live and unsealed; the anchor live in this note | — |

### 5.2 Where a locally valid plan meets remotely changed state
- **A cut against changed text** (cell 15): the operation cuts the current text at the page's offset; the plan adopts
  the result as `stored`; deliveries compare against `stored` and see nothing; her next save overwrites the other
  device's words. The page does not match the library, and nothing notices until §13.2's leaving check.
- **A join whose texts changed** (cell 20): same mechanism.
- **A join beside a take added remotely** (cell 19): the operation succeeds and strands the take.
- **A keep-on-top divide beside a take added remotely** (cell 18): the operation succeeds and strands the take.
- **A join of "adjacent" blocks after a remote insert between them**: `blocksNotAdjacent`; §8.5 inverts. Sound.
- **A carve of an empty block someone typed into**: refused inside the transaction; §8.5 inverts. Sound.
- **An operation on a block a pull already released** (cell 23): `blockNotPlaced`; §8.5 inverts; keystrokes queued
  behind the token have no defined binding (finding M4).

**The plan's §8.5 says "If the operation's outcome differs from what the map expected (a race: another device added a
take a moment ago, so a join is suppressed), the page is brought to the outcome."** That is true of the compound, which
reads the fan at run time and reports `joinSuppressedByFan`. It is not true of the seam join: `merge` does not look at
fans, so its outcome never "differs" — it silently strands the take. And §10.1's rule ("each touched region's stored
text is set from the operation's result") is what turns a stale plan into a silent clobber: it makes the operation's
re-read text the save base while the page still shows the old text.

### 5.3 The fix, from the codebase's own precedent
The MCP door's `divideBlock` and `mergeBlocks` (`Operations+MCPEdits.swift:352-439`) re-verify, inside the act's
transaction, "the fan it composed over, ids AND texts … and the measured take still this block's RENDERED take … when
one did, ONE honest refusal, never a cut in a place nobody chose." The phone's doors should pass the same kind of
`WriteGuard` on every structural operation: the ids and texts of every take the ruled page was computed from, the fan
membership the rule read, and the adjacency the join assumed. A refusal is `bufferChangedSinceGesture`, and §8.5 inverts
only the difference. This is the compound's own law stated for every door: "the projection may enable a road and never
authorize one" (`CrossBlockCompound.swift:527-531`). The door can stay synchronous inside the keyboard's call (it
decides from the map); the transaction authorizes. No operation's contract changes: `guardedBy` is already there.

And §10.1 must change: **`stored` takes the operation's result only when that result equals what the page was ruled
to show**; any difference means the guard was missing, and the region is treated as a failed act.

---

## 6. Deliveries onto the page (§12.2)

### 6.1 For each remote shape
Columns: (a) a region she is not in · (b) the region her caret is in · (c) a region with unsaved typing · (d) a region
holding a token.

| Remote shape | (a) | (b) | (c) | (d) |
|---|---|---|---|---|
| Block inserted | through her own calls: fine | (insert beside her region) fine | fine | fine |
| Block removed (delete) | removed | lower, rebuild, raise — **from what?** If from the projection, her unsaved text in this region is gone | kept (the rule) → refused save → §4's rescue | the act is queued against a dead block → refused → §8.5 → M4 |
| Divided, one take (same id, shorter text, new block after) | updated | rebuild | kept → S5 at the next save; the page shows the second half twice | the act's guard refuses or the op runs on new text (B1) |
| Divided with takes (id gone, B and C new) | replaced | rebuild | kept → duplicate → rescue (§4) | refused |
| Merged (two ids gone, M new) | replaced | rebuild | kept → duplicate → rescue; with §4, rebase into M | refused |
| Moved to another note | removed | rebuild | kept → plan refuses → duplicate (cell 9) | refused |
| Reordered | must be a **move** of the region with its binding and its page text | rebuild (must keep her page text) | must move her page text | the token must travel with the region |
| Chosen take flipped | rebind and replace text | rebuild | undefined (m3) | — |
| Gap slot appears | read-only, empty | **a region turning into a gap mid-typing is undefined** (m4) | undefined | — |
| Gap fills | its text appears | — | — | — |
| Tombstone of the shown take, block live | rebind to the fallback take | rebuild | refused save → needs a take rescue (M3) | — |
| Restore | inserted | — | — | — |
| Purge | nothing on the page (only tombstoned rows purge) | — | — | — |

### 6.2 Is "a region with unsaved typing is never overwritten" safe when the change is structural?
It prevents an overwrite but it does not prevent loss or duplication:
- it keeps a region bound to a block that is no longer in the note, so the page shows her paragraph **and** the
  successor holding its older copy (cells 3, 4, 8, 9);
- it says nothing about the words she saved **before** the delivery, which is the common case (§0);
- the plan's rebuild for her caret region ("the keyboard is lowered, the page rebuilt, and the keyboard raised") does
  not say it rebuilds her region from its settled page text rather than the projection; built from the projection, it is
  exactly the overwrite the rule forbids;
- for a region with text still forming, a rebuild throws the forming text away; the plan settles forming text by kind
  only at durability moments (§11.5), not before a rebuild.

### 6.3 What is compared, and what it can mistake
"By block ids in order and by stored texts":
- **A reorder** has the same id set in a different order. A sequence diff can read it as a removal plus an insertion.
  If applied as such, the "inserted" region is built from the delivery's text and its binding, and her unsaved page
  text (if it is her region) is lost or the region loses its token. The comparison must recognise a move as a move.
- **A divide with one take** keeps X's id with shorter text and adds C. Read correctly, it is "X's text changed, C
  inserted"; then cell 2's duplication follows by design. Not a mistake, but the plan should say it is the expected
  outcome.
- **A remote divide immediately undone** (or any act and its undo between two deliveries) shows nothing; fine.
- **The comparison is against `stored`, not the page.** That is the right defence against her own echoes (with the
  `isUnlanded` fence, `AutosaveCoordinator.swift:121-123`), but it is blind to any case where `stored` and the page
  disagree, which is exactly what §10.1's adoption creates (B1).
- **`stored` must not move for a region with unsaved typing.** §5.3 says the map's facts are "kept fresh … a delivery
  updates them at once". If an implementer reads `stored` as one of those facts, the CAS base no longer describes what
  her page text was built on, and the guarded autosave cannot rescue the other device's text (cell 1). The rule should
  be written: `stored` changes only when a save of hers lands, when an operation she made returns (with §5.3's
  equality), or when a delivery is adopted for a region with nothing unsaved and nothing forming. This is the
  coordinator's own rule (`record(basedOn:)`: only the first edit of a run sets the base, `:138-153`).
- **A delivery written onto the page through the text view's own calls must not be read back as her typing.** Rule 2
  re-reads any changed region and saves what it says, and §8.6 treats an unexplained struck break as an accident to
  invert. The delivery's own edits need the Mac's `suppressEditProcessing` equivalent, and `stored` must be updated with
  (not after) the page edit; otherwise the delivered text is re-saved as hers (a spurious write that touches the
  container row and churn, and puts rows in the outbox) or a delivered merge is "repaired" back apart.

---

## 7. Offline and reconnect

The phone makes several structural edits offline (Returns, joins, a compound); the Mac edits the same note; both
reconnect. Walking SyncSpec's apply:

- **Single-ownership repairs (I2).** A collision needs two live placements for one block. The phone's new blocks have
  fresh ids, so its mints never collide. Its re-placements can: a structural undo revives old placement rows (same row
  ids as the Mac knows, so it is a CAS on one row, not a collision); a tray Put back or a rescue that re-places an
  existing block with a fresh row can collide with a Mac move or Put back of the same block. Then the row with the
  higher `server_seq` wins (`Repairs.swift:561-599`). If the phone's row loses, the block leaves this note (or moves
  within it). **The plan's map has no rule for it**, but it reaches the page as an ordinary delivery: a removal or a
  move, so §6 applies.
- **Chosen-variant repairs.** A dangling chosen is nulled and the block renders its default (`Repairs.swift:846-873`).
  The region's binding (block, shown take) then names a take the delivery no longer shows: rebind, and if she has unsaved
  typing in a now-dead take, the take rescue of §4.
- **I10 resurrection.** Only the takes sheet can race it; a `'rescued'` take appears as a fan fact. Fine.
- **Deferred foreign keys.** The pull holds a batch at a row whose referents have not arrived (a stall), so most gaps are
  avoided; the successor's edges can still arrive one batch after its placement when the pusher's rows were split
  across chunks (m5).
- **Gap slots.** §5.4 makes a gap region read-only. The plan does not define a region whose block **becomes** a gap
  while she types in it (m4).
- **The structure × structure duplicates.** Phone Return in X plus Mac Return in X: two successors, a duplicated second
  half, and a conflict take on X (SyncSpec §7's documented class). Phone join plus Mac divide: X's second half twice
  (cell 22). These are visible and lose nothing; their frequency is what F5 changes.
- **What the new editor shows at reconnect.** If the note is open with a map built before the pull, the delivery check
  of §4 sees every removal. If the note is opened after the pull (the usual case under Castle, where every return is a
  fresh unlock and a fresh services start), there is no map from before, and stranded words are only findable by §4's
  store-level backstop.

---

## 8. Under Castle and the phone's lifecycle

Today: every Castle backgrounding runs `performBackgroundFlush` — the quick note filed, `editors.flushAll()` (each
editor's `finish()`), the leaving savepoints, then `sync.flush()` (the `beforeRound` occasion, then a round), then the
lock (`phone-editor-inventory.md` §2.4; the lag report T6). What must be true at the lock for nothing to be stranded:

1. **The editor's act queue is empty**: every act has landed, or been refused and inverted. An act still queued when the
   lock closes the pool fails with `StoreLockedError`; the page had the ruled structure, the library does not, and every
   keystroke queued behind its token is lost.
2. **Every token is bound or reverted**, and the saves queued behind a refused token have been handed to the
   pre-gesture binding (M4), which then meets the check and the rescue.
3. **The coordinator is clean or every refused entry has been rescued.** A refused entry kept pending at the lock dies
   with the session (the coordinator is in memory).
4. **The open end is minted**, or, under a seal or a deleted note, its words are said to be lost.
5. **`hasPendingAutosave` must see the act queue.** VX-683 A's flush before every round short-circuits on
   `hasPendingAutosave`, which reads only the coordinators (`AppSession.swift:421-423, 634-639`; wired at
   `AppServices.swift:263-266`). Token-held saves and queued acts are invisible to it, so a round can pull before her
   pending words land. That reopens VX-683's hole for exactly the regions the plan is most careful about. The plan's
   "every flush road also waits for acts in flight" (§11.1) must name this road explicitly.
6. **The durability order needs a flush after the last act.** §11.5's order is "settle, mint, flush the saver, wait for
   acts in flight". Saves held behind a token are released only when the act binds it, i.e. after "flush the saver". The
   order should end: drain the act queue (which flushes before each act), then flush once more, then go on.
7. **A rescue the background round's pull triggers** runs after that round's push, so it is pushed at the next unlock.
   That is fine locally, provided the editor is still alive to run it before the lock (point 1). If the lock tears the
   screen down first, the rescue never runs: the §4 backstop is what catches it at the next open.
8. **The one-writer belt** (`PullStage.isOneWriterRefusal`: two rounds racing the pull cursor or stage) does not touch
   editor writes. I found no interaction.
9. **The writer can be held by a sync apply for a long time.** The pull's apply is one write transaction; a large
   catch-up's apply has taken tens of seconds (VX-497/VM-184, still open). Every save and act waits on the writer
   meanwhile, so tokens stay unbound and typing waits in memory. §11.6's "measured in milliseconds on an ordinary note"
   is true of the operation, not of the wait; a kill during a catch-up's apply loses everything typed since it began.
   §11.6 should say so, and §14.5 should measure a token's life during an apply.

Words the library refuses at a lock (a seal or a note deleted elsewhere) are lost when the screen goes. Keeping them in
memory across a Castle lock is a protection question (`notes/CastleRules.md` governs what may outlive a lock); I did not
read it for this review, so I cannot say whether parking them is allowed (D7).

---

## 9. The Mac's behaviour for the same hazards

The plan says the Mac's editor does not change. What the Mac does today in the same cells:

- **The Mac's saves land silently in a block the phone released.** The Mac's projection policy defers every delivery
  while its coordinator is dirty (`EditorProjectionEngine.swift:153-154`), the coordinator flushes into the released
  block (no placement check, F1), and the next clean moment re-reads the store and full-renders the new sequence
  (`EditorViewModel.swift:924-990, 1116-1163`). Her Mac words vanish from the Mac's page, silently, into lineage. Same
  hole, same mechanism.
- **The Mac's refused save stays pending forever**, and while it is pending the Mac defers every projection for that
  note, so its page stops showing remote changes until she acts (`AutosaveCoordinator.swift:166-178`).
- **The Mac's structural doors are safer than the plan's in one way:** after a structural act the Mac renders from the
  store, so a stale plan never leaves the Mac's page and its save base apart (B1 is new to this plan). Its seam join reads
  fans from the store at run time (`EditorSurfaceController.swift:2470-2534`); the plan reads them from the map (M2).
- **The new phone editor makes the Mac's exposure more frequent.** Cells 17, 19 and 21: a Return in a block with takes,
  or a backspace join, on the phone now releases blocks the Mac (or an agent on the Mac) may be writing in. Before this
  plan, the phone released blocks only through deliberate menu acts.

**So the hazard is shared, and it is not the phone's alone to fix.** That changes how the fix should be designed: the
stranded-words decision is a pure function that both editors can call (shared brain or core Domain), the delivery check
is per editor, and the store-level backstop is a query both can show. And it changes who decides: fixing it on the Mac
is a change to the Mac's editor, which the plan's §0 forbids, and which is hers to allow or to ticket (D5).

---

## 10. Findings, ranked

### BLOCKERS

**B1 — A structural act planned on one text and run on another overwrites the other device's words, silently.**
*Sequence:* the Mac edits X (an agent's `edit_take`, or her own typing pushed earlier). The phone's round pulls it; the
rows are committed; the phone's delivery has not reached the map (a projection fetch on a long note takes hundreds of
milliseconds, VM-69). She presses Return in X. The door rules the cut on the page's old text and writes the ruled page;
`divide(X, cut:)` cuts the Mac's text at that offset (`+Structural.swift:222-231`, no text precondition). §10.1 sets
both regions' `stored` from the result. The delivery that follows compares against `stored` and finds nothing to change.
Her next keystroke saves old-based text with `expectedText` equal to the row: no card, **the Mac's words are gone from
every device** (the old texts survive only in the insurance commits, if any). The same for a backspace join (`merge`
joins the current rows) and the menu's acts. *Evidence:* the operations' bodies (§5.1); the plan's §10.1 and §12.2
(compare by stored texts); the MCP door guarding the identical race (`+MCPEdits.swift:357-372`). *Change:* every
structural operation the new editor sends carries a `WriteGuard` re-verifying, inside its transaction, the ids and texts
of every take the ruled page was computed from, the fan membership the rule read, and the adjacency it assumed; §10.1
adopts an operation's result as `stored` only when it equals the ruled page.

**B2 — Words saved before the phone hears of a remote merge, keep-on-top divide or archive are stranded in lineage, in
every order, and the plan's check does not see them.**
*Sequence (Order A):* the Mac merges P and X and pushes (two placements tombstoned, two block rows updated, M minted).
On the phone she is typing in X; her saves land locally (X is still placed locally) and the next round's flush lands the
rest. The pull applies the Mac's rows; her take's row is not among them, so nothing merges. The push sends her take; the
server accepts (no other device wrote it). *Order B:* the phone pushes first; the Mac merges without having pulled; M
holds the Mac's older copy of X. *Interleaved:* the same end. *After convergence:* M (the older copy) placed; X
(her newer words) released. *The phone's page:* the delivery removes X and its partner and inserts M. If she paused
for more than half a second before the delivery (very likely: the round runs 3 s after the outbox changes, then pulls),
the region has nothing unsaved and is replaced by M. **Her words leave the page and the note, with no line.** With
unsaved typing, the region is kept, the next save is refused by §11.3 and rescued as a new block beside M, which holds
the older copy: a duplicate paragraph. *Evidence:* F1, F2; `Repairs.swift:486-494`; the lag report §1c. *Change:* §4's
delivery-time check (rebase into the successor where it can be composed, rescue where it cannot), plus the store-level
backstop at open; the convergence tests of §11 with the "words reachable from the note" assertion. §11.3's parameter
becomes optional (D2).

### MAJORS

**M1 — §12.2 does not define structural deliveries for the region she is in or has unsaved typing in.**
(a) It keeps a region bound to a block that left the note, which duplicates the paragraph beside its successor
(cells 3, 4, 8, 9). (b) "Lowered, rebuilt, raised" does not say the rebuild keeps her region's settled page text (and
its forming text, settled by kind) rather than the projection's, and a reorder must move a region with its binding,
token and page text (§6.3). (c) It must state that `stored` never moves for a region with unsaved typing, or the
guarded autosave cannot rescue the other device's text (cell 1). (d) Deliveries applied through the text view's own
calls must be suppressed from rule 2 and §8.6 (§6.3). *Change:* write the rebase rule of §4.4 into §12.2, the four
statements above, and give the identity oracle (§14.2) delivery cases.

**M2 — The doors authorize from the map, where the Mac authorizes from the store.**
The seam join and a Return in a block with takes are refused or composed from the map's fan, which deliveries keep only
as fresh as the last delivery. `merge` does not check fans, and `divideW` does not check fan membership, so a take
another device added a moment ago strands in lineage, silently (cells 18, 19). §8.5's "a join is suppressed" is the
compound's behaviour, not the seam join's. *Change:* the guard of B1 includes both blocks' live active fan membership;
a refusal inverts (§8.5) and says the fan's sentence. Evidence: the Mac's own rule ("never `model.slots`",
`EditorSurfaceController.swift:2520-2534`), the compound's ("never authorize from stale state",
`CrossBlockCompound.swift:527-531`).

**M3 — The rescue's single shape duplicates text and contradicts the model in three causes.**
A new block for a locked take contradicts "edit by branching" (OverallModel §3); for a remote delete it re-creates what
the canon lets the delete win (SyncSpec §6); for a move it duplicates words that are visible in the other note. No row
covers a deleted shown take on a live block (cell 12). *Change:* §4.4's per-cause table; the shapes are hers (D3).

**M4 — Saves held behind a token that never binds have no home.**
A refused act (`blockNotPlaced`, `blocksNotAdjacent`, a guard refusal) leaves the token unbound; §8.5 inverts the page,
but the keystrokes typed in the token regions meanwhile were held "in order behind the operation" for a binding that
will never exist. *Change:* on a refused act, each token region reverts to its pre-gesture binding with its settled
page text, and its held saves are released to that binding, which then meets the guard and §4.

**M5 — A refused save left in the coordinator retries forever.**
The coordinator puts a refused entry back into `pending` (`AutosaveCoordinator.swift:233-247`), so `isDirty` stays
true, every round's `beforeRound` flushes it and refuses again, `notifyError` fires every time, and on the Mac the same
posture defers every projection. *Change:* the rescue removes the entry (a coordinator entry point such as
`discard(variantID:)` once the rescue has landed), in the same task, in order.

**M6 — VX-683 A's flush before every round cannot see the editor's act queue.**
`hasPendingAutosave` and `flushPendingTypingBeforeRound` read only the coordinators (`AppSession.swift:421-423,
634-639`). Queued acts and token-held saves are skipped, so the round can pull before her pending words land, and the
pull then meets clean rows. *Change:* the act queue registers with the session so `hasPendingAutosave` includes it and
the flush drains it; §11.5's order ends with a flush after the last act (§8 point 6).

**M7 — The plan raises the rate at which the Mac's words strand, and leaves the Mac unchanged.**
Cells 17, 19, 21: Return in a block with takes and the backspace join release blocks on the phone that the Mac or an
agent may be writing in; the Mac saves into the released block and its page drops the paragraph silently (§9). *Change:*
design the stranded-words decision once (shared), name the Mac's adoption as its own ticket or bring it in scope; her
call (D5).

**M8 — SyncSpec's accepted structural duplication rests on a premise this plan removes, and the plan's canon list
omits SyncSpec.**
SyncSpec §7 accepts concurrent-divide duplication because "structural editing is desktop-only by product design"; §1
describes mobile's surface as "create entries, edit active text". Under this plan Return and backspace are structural
on the phone, the leaving round often fails to push (the lag report, cause 4), and an agent on the Mac makes structural
edits. Duplicated second halves and conflict takes (cells 2, 5, 16, 22, 23) become routine rather than rare, and the
version-restore race (cell 7) becomes reachable. *Change:* put the premise to her (D4); add SyncSpec §1 and §7 to §22's
canon deltas; ticket the Delete Now ride (cell 7) whichever way she rules.

### MINORS

- **m1 — Container metadata is server-wins, and every autosave writes the container row.** The plan's per-note
  segmentation switch (§10.3) writes `container.segmentation_default`; flipped on one device while the other is typing
  in the same note, it is lost in one order (as a rename is — the accepted class). The same class drops a Mac seal or a
  Mac take lock racing phone typing (cells 13, 14). Pre-existing for the seal and the lock; new exposure for the
  switch. Test it and say it; a fix (re-applying metadata intent, or moving touch and churn off the container row) would
  be `Sync/` work, the Fable class, and hers.
- **m2 — "The region's place" needs an anchor rule** (§4.1).
- **m3 — A chosen take flipped by another device while she types in the old one** has no defined behaviour (keep as a
  peek until she pauses, then rebind and say?).
- **m4 — A region that becomes a gap slot mid-typing** has no defined behaviour.
- **m5 — The successor can arrive a batch after the release**; the stranded-words check waits one delivery when the
  removed block has no identifiable successor.
- **m6 — Words the library refuses after a remote seal or note delete are lost at leaving**, and the unsaved half-second
  before a remote note delete is lost; the line should say "not saved" plainly, as §11.4 does for the seal.
- **m7 — The compound's legs are separate transactions**; a round between them pushes intermediate rows that a third
  device can briefly see; it converges after the rollback. The recorded residual; state it in the plan.
- **m8 — If §20.1's parameter is kept**, use the house `guardedBy:` precondition with one shared guard factory, so the
  Mac can adopt it without a second idiom; it is not a §12 event.
- **m9 — §11.6 understates a kill's exposure while a sync apply holds the writer** (§8 point 9).

---

## 11. What the plan's tests must add for sync

The two-client fake-server harness exists in the core package: `FakeSyncServer`, `SyncClient`, `productionRound`,
`productionQuiescence`, `assertConverged` (see `SyncConvergenceTests.swift`, `StructuralSessionSyncTests.swift`). These
tests are headless `swift test`, need no stage claim, and need no `Sync/` source change. **Each must assert more than
convergence:** after quiescence, on both clients, every text either client typed is in the note's rendered text, in a
take of a block placed in the note, in the Trash, or in a recorded "said" outcome. A pin that is green on both sides of
a fix is hollow (the hallucination guard).

1. **Merge × typing**, Orders A, B and interleaved (Mac pull, phone pull, Mac push, phone push), with the phone's
   §4 rebase and rescue modelled as the operations they run. Red on today's code (her words in a released block).
2. **Keep-on-top divide × typing**, the same three orders.
3. **Archive × typing; move × typing; delete × typing** (the Trash ride asserted); **version restore × typing** (cell
   7 — documents the loss today).
4. **The stale plan** (B1): a pull lands a text edit between the door's plan and `divide`; with the guard the
   operation refuses, without it the Mac's words are gone. Red on old by revert.
5. **The seam join beside a remotely added take** and **keep-on-top beside a remotely added take** (M2): red without
   the fan guard.
6. **Single divide × typing and extract × typing**: the S5 conflict take, and the duplicated half documented as the
   expected outcome.
7. **Structure × structure**: phone Return × Mac Return in the same block (SyncSpec §7's class, now from the phone's
   door); phone join × Mac divide; phone divide × Mac merge. Documenting tests, so the duplicates are never a surprise.
8. **The compound × a remote insert between its ends**, with a round run between its legs: converges, nothing lost.
9. **Only the writer rescues**: both clients run the stranded-words decision over the same converged rows; exactly one
   rescue exists afterwards; two clients that both typed produce two versions, never a duplicate of one.
10. **Container metadata**: the per-note switch × typing on the other client; a seal × typing; a take lock × typing
    (documenting m1).
11. **The adversary of §14.3 is a real second `SyncClient` running real rounds**, not an in-process library mutator,
    so the reject-merge, tombstone ride and repairs actually run. Its kill points include "after the pull, before the
    delivery reaches the map" and "after the push, before the pull of the other's release".
12. **The composition (phone test target, under a stage claim):** the delivery compare recognises a reorder as a move;
    a delivery written through the text view's own calls is not re-saved; a rebuild of her region keeps her settled
    page text; `stored` does not move under unsaved typing; a refused act releases its held saves to the pre-gesture
    binding; `hasPendingAutosave` sees the act queue; the background order drains acts, then flushes, then rounds, then
    locks.

**Does any recommended change touch `Sources/VariorumCore/Sync/`?** The recommended road does not: the guards use
`guardedBy`, which the operations already take; the stranded-words decision is a pure function and a map fact; the
backstop is a query; the rescues are existing operations. Two options in this review would: an engine rule that detects
a release meeting a dirty take (§3.3), and any fix to container metadata being server-wins (m1). Either is `Sync/`, a
SyncSpec §6/§7 change, the Fable review class, and her ruling.

---

## 12. The decisions that are hers alone

**D1. Where are stranded words caught?**
(a) At the save, as the plan has it: catches only saves made after the phone has heard; leaves the common case silent.
(b) **At the delivery, in the editor that wrote them, plus a store-level hint at open** — one rescuer per edit in every
order; no operation or `Sync/` change. (c) In the sync engine: a new SyncSpec rule; cannot see the interleaved order
without a dedupe repair. *Recommendation: (b).*

**D2. Does `autosave` gain the placement check (§20.1)?**
(a) Yes, as a `guardedBy:` precondition shared with the Mac. (b) No: the delivery check covers what it would refuse, and
the operation's contract stays as it is. *Recommendation: (b) if she takes D1(b); (a) is harmless belt-and-braces.*

**D3. What is the rescue, per cause?**
Merge: rebase her words into the merged block, else a new block before it (recommended). Divide with takes: a new block.
Delete or archive elsewhere: (a) the delete wins and her words are in the Trash or tray, said with Put back (the canon's
answer, recommended), or (b) re-create the paragraph (the plan's). Move elsewhere: (a) her words follow the block and
the line says where (recommended), or (b) a copy here (the plan's). Locked take: a branch take on the block
(recommended) or a new block (the plan's). Shown take deleted: a take on the block. And the sentences for each.

**D4. SyncSpec §7 accepted duplicated paragraphs from concurrent structural edits because structural editing was
desktop-only. With Return and backspace structural on the phone, is that still acceptable?**
(a) Yes, accepted knowingly, with the canon line rewritten to say why. (b) No: a phase of its own to design convergence
for concurrent divides (a `Sync/` event). *Recommendation: (a) now, with the documenting tests of §11 item 7, and the
rate watched in the trial's trace.*

**D5. The Mac has the same stranding hole, and this plan makes it more frequent.**
(a) Bring the Mac's delivery check into this effort (it breaks §0's "the Mac's editor does not change", for a shared
safety rule). (b) Ticket it, to follow once the phone's version is proven. (c) Accept. *Recommendation: (b), with the
decision function written shared from the start so the Mac's ticket is a hook, not a design.*

**D6. When a structural act is refused because the library moved (B1's guard), what does the page do?**
(a) Undo the gesture on the page and say so (the plan's §8.5): she presses Return again. (b) Re-plan with the fresh
facts and apply the new ruled result: smoother, but a second structural change she did not see coming. *Recommendation:
(a).*

**D7. Words the library refuses at a lock or a leaving (a remote seal, a note deleted elsewhere): lost and said, or kept
somewhere?** Keeping her plaintext across a Castle lock is a protection question for `notes/CastleRules.md`.
*Recommendation: lost and said plainly, unless CastleRules allows a park.*

---

## 13. What I could not determine without running the harness

- Whether the version-restore ride (cell 7) is really purged before anyone can see it, or whether some path surfaces
  the ridden row first. I traced the fence and the horizon in prose, not in a run.
- How often a delivery lags a pull's commit on her phone (B1's window); VM-65's readout does not separate it.
- Whether a structural push is ever split across chunks so that a successor's edges arrive a batch after its release
  (m5); the drain order sorts by table, so it depends on the row counts of one act.
- Whether `Queries.lineageTree`-based or `unplacedOrigins`-based successor discovery is cheaper on a long note; both are
  ∝ the removed blocks' lineage by their own documentation.
- Whether the MCP door's grant fence already refuses an agent's write to a released block (I expect so, because a
  released block resolves to no note; not traced).
- I did not read `notes/CastleRules.md` or `notes/MCPSpec.md` for this review; D7 and the §3.3 MCP line need them.
