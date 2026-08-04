-- Variorum sync mirror — the Phase 14b ONE-TIME GATE ACT (ruling R-2:
-- wipe-and-repush; authored at ladder finding R1-1). This is NOT schema
-- choreography: the file lives deliberately OUTSIDE the numbered lockstep
-- chain (01–08 stay schema-only), bumps NO marker, and is run EXACTLY ONCE —
-- at the gate's step 4, behind the A1 rail + a mirror export, at the
-- author's explicit go. Never headless, never part of any deploy sequence,
-- never re-run.
--
-- WHAT IT DOES: empties the EIGHTEEN sync data tables — exactly the
-- SyncSchema registry, pinned order-insensitively by AuthRLSDDLTests (a
-- table skipped here would keep pre-14b PLAINTEXT rows that the decrypt
-- seam then refuses on every pull: a permanent cursor wedge, the
-- run-too-early class made durable) — so the Mac's resyncReinitialize +
-- repush lands the whole corpus as `e1:` ciphertext.
--
-- WHAT IT NEVER TOUCHES: key_vault (the account's wrapped keys — emptying
-- it would orphan the whole ciphertext corpus), sync_meta (the §12 lockstep
-- marker), anything in auth.*. And deliberately NO `restart identity`: the
-- global server_seq sequence stays monotonic — ordering authority is never
-- reset (SyncSpec §9; THE DESIGN's R-2 paragraph).

truncate table
  container,
  block,
  variant,
  commit_point,
  tag,
  edge,
  container_block,
  reading,
  reading_section,
  reading_post,
  post_tag,
  block_tag,
  reference,
  canvas_layout,
  lens,
  lens_choice,
  block_comment,
  setting;
