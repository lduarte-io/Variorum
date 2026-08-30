# Proactive Tech Debt Review — 2026-08-30

**Status: a review artifact, not canon.** Nothing in this file has been fixed, and nothing in it
has an owner yet. It does not amend `KnownIssuesAndTechDebt.md` — that file's rule is that no entry
exists without a named owning phase, and assigning owners is the author's call. This is the input to
that call, not the output.

## What this is

A proactive, whole-codebase sweep run on 2026-08-30 at the author's instruction, immediately after
Phase 13p closed. It is not a phase review and it is not tied to a diff: it reads the shipped tree as
it stands and asks what is wrong with it.

## Method

**18 independent review lenses**, each a cold agent with no knowledge of the others' work, fanned out
over a partition of the tree by both AREA (persistence, operations lifecycle, the structural core,
undo/redo, the sync engine, purge, crypto, the bridge, queries, domain, the shared editor brain, the
Mac editor, the Mac boards, mobile) and by LENS (concurrency, architecture conformance, silent
failures, test integrity).

**Every finding was then adversarially verified** by a second cold agent whose instruction was to
REFUTE it by opening the real code, defaulting to refuted under uncertainty, and treating a
documented-and-owned tradeoff as refuted rather than confirmed.

**The project's own hallucination guard was the binding constraint on both halves:** no finding
without a traced concrete mechanism — specific inputs or state to a specific wrong outcome — and no
finding without verbatim code evidence at a file:line. "This looks fragile" was not admissible.

| | |
|---|---|
| Lenses run | 18 of 18 |
| Agents | 36 (18 find + 18 verify), 0 errors |
| Raw findings | 65 |
| **Survived refutation** | **50** |
| Refuted and dropped | 15 |
| Confirmed / Plausible | 49 / 1 |
| Already in KnownIssues | 1 of 50 — **49 are new** |

Severity is the VERIFIER's corrected severity, not the finder's claim. Confidence is the finder's,
kept as a hedge signal; the verdict is what carries weight.

## The five things worth reading if you read nothing else

1. **An unreadable key sidecar is read as absent, and the next launch overwrites it** (P1 below).
   A truncated or transiently-unreadable `variorum-keys.json` — the ordinary artifact of an
   interrupted folder copy — causes the escrow reconcile to write a fresh empty envelope over it on
   the very next launch, with `try?` swallowing even a failed write. The written-down recovery phrase
   stops opening the library, silently. The file states the opposite rule about itself forty lines away.
2. **Three more roads in the same credential family** reach the same class of outcome (P2, P10, P11),
   and `StoreFilePresence.classify` reporting an unreadable store as `.absent` (P12) would authorize a
   fresh key mint over an encrypted store. This family is the single largest cluster in the sweep and
   it is all one root: **typed errors that exist precisely to distinguish corruption from absence are
   discarded by `try?` at the consumer.**
3. **Two O(N^2) walks run on the keystroke road** (P16, P17) — `seamPair` on every caret move and
   `applyDifferential` per slot — beside the one already-known twin. P1 is violated on the typing path,
   on both platforms.
4. **Churn is computed from AppKit's WIDENED edited-range report** (P24, P25), so a one-character typo
   fix inside existing prose over-reports churn by roughly twice the paragraph tail — which means the
   80%-sort's whole purpose (fixing one typo must never reshuffle the library) is defeated by the
   mechanism recorded in TEXTKIT2_NOTES as a measured macOS 26 behavior.
5. **A CRLF file imports as ONE block** (P23). `SegmentationRules` splits on `\n` only.

---

## T1 — Data loss, credential destruction & corruption

Findings whose traced mechanism ends in her writing, her recovery phrase, or her store being destroyed, orphaned, or silently wrong. Nothing here is theoretical — each one names the inputs that reach it.

### P1. An unreadable variorum-keys.json is read as absent, so the next launch silently overwrites it with an empty envelope — destroying the passphrase and recovery-phrase wraps

`App/Variorum/Shared/ProtectionController.swift:159`

**MAJOR** · CONFIRMED · data-loss · lens: persistence+migrations · confidence 0.85

**Mechanism**

StoreKeyEnvelope.load throws a typed `unreadable` specifically so corruption is never read as absence, but both consumers discard it with `(try? gate.loadEnvelope(...)) ?? nil` (ProtectionController.swift:159, AppBootstrap.swift:438). `ensuredEnvelope` (ProtectionController.swift:161-169) therefore cannot tell 'no file' from 'unreadable file', and only the FOREIGN branch gets the protective `setAsideEnvelope` move — the unreadable case falls through to `return (StoreKeyEnvelope(), false)`. Concrete path, no user action needed: a zero-byte or truncated sidecar (the ordinary artifact of an interrupted copy of the library folder, a half-finished restore from a backup folder, or a transient read error) decodes as `unreadable` because fileExists is true, Data(contentsOf:) succeeds and JSONDecoder throws. AppBootstrap.finish fires `protection.reconcile()` on every ready launch (AppBootstrap.swift:351-353); with the escrow dial ON, reconcileEscrowOffMain (ProtectionController.swift:488-493) calls ensuredEnvelope, sees `!ensured.onDisk`, and runs `try? gate.saveEnvelope(envelope, ...)` -> StoreLaunchGate.live's `try $0.write(at:)` -> `data.write(to: url, options: .atomic)` (StoreKeyEnvelope.swift:221), an unconditional replace. The fresh envelope carries a NEW random storeID, so `guardSeam.loadEscrow(envelope.storeID) != key` is true and a new iCloud escrow item is written, orphaning the old one. After one launch the passphrase wrap and recovery wrap are gone, the twelve words the user wrote down open nothing, and the `try?` even discards a write failure. Two further roads reach the same replace: refreshEnvelopeFacts (:124-128) sets hasPassphraseWrap/hasRecoveryWrap false from the swallowed nil, so resetPassphrase refuses with 'No passphrase is set yet — use Set a Passphrase instead' (:229) and StandardNudgePolicy (:529) raises the set-a-passphrase nudge — both steering into setPassphrase -> ensuredEnvelope -> saveEnvelope. Third consequence at launch under a demanded mode: passphraseOffered/recoveryOffered come from the same swallowed nil, so StoreLobby.noRoadExists (StoreLaunchGate.swift:172) is true and StoreLockView renders `deadEnd` (StoreLockView.swift:40-43) asserting a false cause — 'no passphrase or recovery phrase is on file beside the library' (StoreProtection.swift:452-457) — over a library where the file is present.

**Evidence**

> StoreKeyEnvelope.swift:201-203 — "A file that EXISTS but cannot be decoded throws `unreadable` — reading corruption as absence would let a surface claim \"no passphrase is set\" over a library that has one."  ||  ProtectionController.swift:159 — `(try? gate.loadEnvelope(storeURL ?? URL(fileURLWithPath: "/dev/null"))) ?? nil`  ||  ProtectionController.swift:165-168 — `if let existing = loadEnvelope(...) { if existing.belongs(to: key) { return (existing, true) }; gate.setAsideEnvelope(...) }; return (StoreKeyEnvelope(), false)`  ||  ProtectionController.swift:490-492 — `if !ensured.onDisk { try? gate.saveEnvelope(envelope, storeURL ?? URL(fileURLWithPath: "/dev/null")) }`  ||  ProtectionController.swift:382 — "`setAsideEnvelope` a move, never a delete"  ||  StoreProtection.swift:477-484 — the correct, currently-unreachable sentence: "This library's key file exists but can't be read. Restore \(StoreKeyEnvelope.filename) from a backup folder..."  ||  ProtectionController.swift:579-598 (makeStoreSecretCheck) does it right: `try gate.loadEnvelope(...)` with a typed catch returning `.couldNotCheck(ProtectionCopy.message(for: error))`.

**Why it matters**

This is the credential family's disaster road for a whole-store-encrypted library. The recovery phrase exists so that a lost device Keychain item is survivable; this path removes it automatically, at launch, with no message — and it fires on exactly the flow 13x's 'AirDrop your library' promise depends on (a copied library folder whose sidecar arrived incomplete). It also violates the file's own stated rule, quoted forty lines away, that a sidecar is set aside and never deleted. The 13p ladder's R1-M3 fix covered the empty-custody case; the unreadable-sidecar case was not covered, and it is not in KnownIssuesAndTechDebt.md.

**Verifier**

Traced end to end in the real source. StoreKeyEnvelope.load (Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:201-211) throws .unreadable for a file that exists but will not decode, with the doc comment stating exactly why absence must not be inferred; the 13p plan file (line 1481) repeats the design promise verbatim ("a corrupt sidecar THROWS (never reads as 'no passphrase')"). Both consumers then discard it: ProtectionController.swift:159 `(try? gate.loadEnvelope(...)) ?? nil` and AppBootstrap.swift:438. ensuredEnvelope (ProtectionController.swift:162-170) is exactly as quoted — the setAsideEnvelope move fires only on the FOREIGN branch; nil (which now means absent-or-unreadable) falls through to `return (StoreKeyEnvelope(), false)` with a fresh random storeID (StoreKeyEnvelope.init default `UUID().uuidString.lowercased()`). The overwrite road is live and default-on: escrowOn defaults true (StoreProtection.swift:49, and :115 reads the inverted `escrowOff` key so an unset default reads ON); AppBootstrap.finish schedules `protection.reconcile()` on every non-test ready launch (AppBootstrap.swift:351-353); reconcile's escrow arm (ProtectionController.swift:486-493) takes `residentKey ?? guardSeam.loadAuto()` — satisfied under the default Auto mode — then `if !ensured.onDisk { try? gate.saveEnvelope(...) }`, whose live implementation is `try $0.write(at: ...)` → `data.write(to: url, options: .atomic)` (StoreLaunchGate.swift:46, StoreKeyEnvelope.swift:219-221), an unconditional replace of the existing file. `loadEscrow(newStoreID) != key` is then necessarily true, so a second escrow item lands and the old one is orphaned. I looked for the refutations and none holds: no caller anywhere sets aside on unreadable (setAsideEnvelope has exactly one production call site, the foreign branch); no test pins this behavior (every controller/lobby test drives StoreLaunchGate.scripted, whose loadEnvelope closure cannot throw, so the unreadable case is entirely unexercised); nothing in notes/ or KnownIssuesAndTechDebt.md records it as an accepted consequence; and AppBootstrap's own comment ("tolerant of an unreadable sidecar (the lobby's roads re-load and WORD that refusal)") is only deliberate for the FACTS road, not for the controller's write road — and even there it is defeated when both offers read false and StoreLobby.noRoadExists renders ProtectionCopy.deadEnd's false cause over a present file, while the correct .unreadable sentence (StoreProtection.swift:477-484) stays unreachable because no door renders to trigger a re-load. One honest temper on impact: when the file is genuinely corrupt its wraps were already unusable, and restoring the sidecar from a backup folder still heals afterwards (the fingerprint match makes it belong again) — the strict destruction case is a transient read failure (I/O error, permissions, a concurrent replace by a backup/sync tool), where good recovery legs are replaced with no message and `try?` even swallows a failed write. That still violates two rules the file states about itself, silently, at launch, on the credential-insurance layer.

---

### P2. Entering a demanded at-open mode is authorized by a cached `hasPassphraseWrap` projection that two doors invalidate without refreshing, so the mode transition can delete both Keychain items over a wrap-less envelope

`App/Variorum/Shared/ProtectionController.swift:311`

**MAJOR** · CONFIRMED · data-loss · lens: crypto & key custody · confidence 0.82

**Mechanism**

`hasPassphraseWrap` is written ONLY by `refreshEnvelopeFacts()` (:124). Two doors call `ensuredEnvelope(for:)`, which SETS ASIDE a foreign sidecar and writes a fresh WRAP-LESS envelope, and neither refreshes afterwards: `setEscrow(true)` (:354-393, ensuredEnvelope at :360) and `reconcile()`'s escrow arm (refresh at :452, ensuredEnvelope at :488, no re-refresh). Concrete road, all through app doors: (1) a demanded mode over a store whose file is gone/unreadable takes `.openResettingModeToAuto` (AppBootstrap.swift:228-236), which mints a NEW store key — the old `variorum-keys.json` is now FOREIGN (fingerprint mismatch); (2) `init`'s `refreshEnvelopeFacts()` reads that foreign envelope, so `hasPassphraseWrap = true`; (3) `reconcile()` (escrow ON is the Standard default) sets the foreign sidecar aside and writes a fresh envelope with NO passphrase and NO recovery wrap, leaving the stale `true` in place — ProtectionPane.swift:353 now renders "Passphrase — Set" over a library that has none; (4) the user picks "Ask for the passphrase": `setMode` passes the stale guard at :311 and runs `guardSeam.deleteAuto()` / `deleteGated()` (:333-334), keeping `residentKey` so the session still works; (5) next launch routes to `.lobby(demand: .passphrase)` with passphraseOffered=false, recoveryOffered=false, biometryOffered=false → `StoreLobby.noRoadExists`. No copy of that store key exists anywhere (the set-aside `variorum-keys.stale-*.json` wraps the PREVIOUS key). The library is permanently unopenable. `setEscrow(true)` over a foreign sidecar reaches the same end state in two clicks. `applyPreset` reads the same stale field at :400.

**Evidence**

> ProtectionController.swift:308-334 — `if newMode.isDemanded { guard hasPassphraseWrap else { return .needsPassphrase } }` … `case .passphrase: guardSeam.deleteAuto(); guardSeam.deleteGated()`; ProtectionController.swift:162-170 — `if existing.belongs(to: key) { return (existing, true) }; gate.setAsideEnvelope(...) } return (StoreKeyEnvelope(), false)`; ProtectionController.swift:452-474 — `refreshEnvelopeFacts()` then the escrow arm, with no refresh after; StoreProtection.swift:441-445 — `deadEnd` claims this state is "practically unreachable through the app's own doors (the mode transitions refuse to enter a demanded mode without a wrap)".

**Why it matters**

Total, unrecoverable loss of the encrypted library — the exact outcome the mode-transition guard exists to prevent, and the state the shipped dead-end copy asserts cannot be reached. It is the project's own named anti-pattern (`deleteBlock`'s doctrine: "a plan-time guard reading a projection is an ENABLEMENT hint, never an authorization"), applied to an irreversible custody deletion.

**Verifier**

Traced in full. `hasPassphraseWrap` is written only at ProtectionController.swift:97 (init) and :452 (reconcile), both via `refreshEnvelopeFacts()`; grep confirms no other writer and no caller elsewhere in either app. `reconcile()` refreshes at :452 and THEN runs the escrow arm at :467-472, whose `reconcileEscrowOffMain` (:485-500) calls `ensuredEnvelope(for:)` — which at :162-166 sets a non-belonging sidecar aside and returns a fresh empty envelope, saved to disk at :490-493 — with no refresh afterwards. `setEscrow(true)` (:354-372) has the same shape and also never refreshes. `setMode`'s only authorization for the irreversible `deleteAuto()`/`deleteGated()` pair (:333-334) is `guard hasPassphraseWrap` at :311, and `applyPreset` reads the same field at :400. The pane never refreshes either (ProtectionPane.swift has no refresh call), so the stale `true` renders as "Passphrase — Set" at :353 and passes the guard. End state verified: StoreLaunchRoute.resolve returns `.lobby(demand:)` for a present store under a demanded mode, `makeLobby` computes passphraseOffered/recoveryOffered from the (now empty) envelope, and `StoreLobby.noRoadExists` is true — the very state StoreProtection.swift:441-445 asserts is "practically unreachable through the app's own doors." CORRECTIONS to the reviewer's road, which narrow it: (a) `reconcile` runs only from `finish(.ready)` (AppBootstrap.swift:352), so a foreign sidecar can only meet it over a store that OPENED — which in practice means the `.openResettingModeToAuto` fresh mint (AppBootstrap.swift:228-236) or a hand-copied wrong sidecar, not an ordinary restore; (b) the set-aside arm requires `dials.escrowOn == true`, and the Locked-down preset (the usual route into a demanded mode) sets escrowOn FALSE, so the compound needs hand-adjusted dials or the Standard default carried forward. Real and unrecoverable when it fires, but a compound of three preconditions rather than a common road — hence MAJOR, not BLOCKER.

---

### P3. The Mac's automatic re-lock never runs `finalizeWork()`, so open-tail text and a pending cross-block compound are dropped and the pool closes under the late teardown

`App/Variorum/Variorum/VariorumApp.swift:81`

**MAJOR** · CONFIRMED · data-loss · lens: silent failures · confidence 0.75

**Mechanism**

`onWillLock` runs only `session.quitFinalize.finalizeAll()` + `services.stop()`. `quitFinalize` holds one closure per open post (AppSession.swift:183) running `savepointOnLeaving`, which is only `flushExistingAutosave` + `closeAutoCommit` (AppSession.swift:378-384). The OPEN TAIL has no variant, so the AutosaveCoordinator holds nothing for it and neither line can reach it. The quit door runs BOTH halves (VariorumAppDelegate.swift:58-65) because `EditorViewModel.finalizeWork()` is the only thing that awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail through `CrystallizationPlanner` + `ops.newBlock`. `finalizeWork` has exactly three callers — the quit door, `teardown()` (fire-and-forget from `.onDisappear`, EditorView.swift:107), and the seal road — and the lock road reaches none. `AppBootstrap.lock():404-427` then sets `state = .locked(...)` and immediately `await Task.detached { binding.lock() }.value`, closing the pool; the `.onDisappear` teardown fires only on the next render pass and its `runner.run { ops.newBlock(...) }` races that close, throwing `StoreLockedError` at `AppDatabase.currentWriter()` onto a view that no longer exists. Concrete: with `relockOnSleepAndScreenLock` on, type a paragraph at the end of a note (in `one_block` segmentation the whole entry is the open tail) and hit ⌃⌘Q or close the lid inside `tailIdleDebounce = .seconds(2)` — the text is on screen, in no row, and the lobby replaces the view.

**Evidence**

> VariorumApp.swift:81-85 `bootstrap.onWillLock = { @MainActor in await session.quitFinalize.finalizeAll(); services?.stop(); services = nil }` vs VariorumAppDelegate.swift:58 `let pendingEditor = session?.editorRouter.active?.finalizeWork()`; AppSession.swift:381-383 `await flushExistingAutosave(forPost: postID)` / `_ = try? await runner.run { ops in try ops.closeAutoCommit(postID) }`; EditorViewModel.swift:1197-1200 `/// the open tail crystallizes after a short quiet gap, so crash loss is bounded to seconds; teardown remains the backstop`; and the phone's correct twin, MobileRelock.swift:99-104 `await editors.flushAll()` → MobileEditorViewModel.swift:461-472 `if mintableTail { idleMintTail() } else { crystallizeIfNeeded() }` / `await awaitMintSettle()`, under a comment calling it "mirroring the Mac's closure"

**Why it matters**

An automatic re-lock is a leaving road, and it is the one leaving road that does not preserve what every other one does — silently losing the paragraph she is typing, plus a scheduled cross-block compound whose triggering keystroke was already refused. The phone shipped the fix (ladder R1-M2) believing it mirrored the Mac; the Mac half was never there.

**Verifier**

Traced end to end and the asymmetry is exactly as claimed. VariorumApp.swift:81-85 wires `onWillLock` to `quitFinalize.finalizeAll()` + `services.stop()` only; the quit door (VariorumAppDelegate.swift:53-68) additionally awaits `session?.editorRouter.active?.finalizeWork()`. The registry's closure is `savepointOnLeaving` (AppSession.swift:367-384) = `flushExistingAutosave` + `closeAutoCommit` — neither can reach the open tail, which has no variant and therefore nothing in the AutosaveCoordinator. Only `finalizeWork` (EditorViewModel.swift:531-587) awaits `pendingCrossBlockTask` (its own comment: "quit/teardown must let it land or the gesture is silently un-applied"), waits out `mintInFlight`, and crystallizes the residual tail via CrystallizationPlanner + `ops.newBlock`. `finalizeWork` is called only from the quit door, `teardown()` (EditorView.swift:107 `.onDisappear { model.teardown() }` — result discarded), and the seal road; `onWillLock` is wired in exactly two places (Mac + phone) and the Mac's is the one without it. AppBootstrap.lock():404-427 then flips `state = .locked` and awaits a detached `binding.lock()`, which nils and closes the writer (StoreBinding.swift:89-102), so the late `.onDisappear` teardown genuinely races the pool close. The phone's twin is the mirror image: mobileWillLock (MobileRelock.swift:90-106) calls `editors.flushAll()` → `MobileEditorViewModel.finish()` (:461-473) which mints the tail — under a comment claiming it mirrors the Mac's closure. One factual nit in the finding: Lock Now is ⌃⌘L (EditorCommands.swift:305-308), not ⌃⌘Q — but ⌃⌘Q is the system screen-lock chord and reaches the same road through the `com.apple.screenIsLocked` observer (ProtectionController.swift:628,654) when relockOnSleepAndScreenLock is on. Severity kept MAJOR: real loss of the paragraph on screen on a deliberate leaving road, no filesystem anomaly required; not BLOCKER because it needs a demanded mode and the ~2 s tailIdleDebounce window.

---

### P4. The comments sheet clears the typed draft before the write is attempted, so a refusal destroys her comment

`App/Variorum/VariorumMobile/Features/Write/MobileCommentsSheetView.swift:105`

**MAJOR** · CONFIRMED · data-loss · lens: mobile app · confidence 0.85

**Mechanism**

`submitDraft()` reads `draftField.text`, sets `draftField.text = ""` (line 105), then fires `Task { await model.comments.submitDraft(text) }` (line 107). `MobileCommentsController.submitDraft` -> `run { }` handles a throw with `model.report(Self.refusalMessage(error))` only (MobileComments.swift:113-140) — nothing restores the field. The refusal is reachable by construction: `MobileCommentsController.open(blockID:)` (MobileComments.swift:50-57) has no seal check (fire-and-DO), and `Operations.addBlockComment` calls `ensurePlacementUnlocked` before anything else (Sources/VariorumCore/Operations/Operations+Comments.swift:29-31), throwing `.lockedPost` under a sealed note — the controller even ships the sentence for it. Concrete run: open a sealed note, tap ... -> Comments, type a paragraph, tap Submit. The field empties, the store gains nothing, and she reads "This note is locked — unlock it to change comments." with her text gone and no undo. The `editBlockComment` arm additionally nils `editingID` before running (MobileComments.swift:114-115), so a refused edit loses the target too. A 13p store re-lock produces the same loss with a raw `String(describing:)` dump as the sentence.

**Evidence**

> MobileCommentsSheetView.swift:101-108 — `let text = draftField.text ?? ""; guard !text.trimming…isEmpty else { return }; draftField.text = ""; draftPlaceholder.isHidden = false; Task { await model.comments.submitDraft(text) }`. MobileComments.swift:128-140 — `do { try await session.runner.run(body) … } catch { model.report(Self.refusalMessage(error)) }`. Operations+Comments.swift:31 — `try ensurePlacementUnlocked(db, blockID: blockID)`.

**Why it matters**

This is the exact class the project has already fixed twice by ruling (the quick note's Q2 — "a leaving that fails keeps her text and says why" — and the Mac QuickEntryBar row): a refusal must never be reached by a road that discarded her text. The Mac twin has the same ordering at Features/Editor/CommentsPanel.swift:184-189, so the correct fix is one shape for both surfaces.

**Verifier**

Traced end to end. MobileCommentsSheetView.submitDraft (lines 101-108) reads `draftField.text`, writes `draftField.text = ""`, then fires `Task { await model.comments.submitDraft(text) }`; `MobileCommentsController.run` (MobileComments.swift:128-140) catches with `model.report(Self.refusalMessage(error))` and nothing anywhere restores the field. The refusal is genuinely reachable: `open(blockID:)` (MobileComments.swift:50-57) guards only that the slot exists, `MobileBlockMenu.menuElements` appends the Comments row unconditionally (MobileBlockMenu.swift:138-140) and `MobileBlockDecor.swift:259` does the same — fire-and-DO, no seal gate — while `Operations.addBlockComment` calls `try ensurePlacementUnlocked(db, blockID:)` before anything else (Operations+Comments.swift:31) and throws `.lockedPost` under a sealed note; the controller even ships the sentence for it ("This note is locked — unlock it to change comments.", MobileComments.swift:152). Nothing in MobileCommentsSheetView gates the draft field or Submit on `isSealed`. So: sealed note → ⋯ → Comments → type → Add empties the field, writes nothing, and prints a refusal, with no undo. The `editingID = nil` before `run` (MobileComments.swift:114-116) loses the edit target on the same road. Severity held at MAJOR: it is unrecoverable text loss on an ordinary gesture over a shipped note state, and the project has ruled this exact class twice (the quick note's Q2 rule, stated at MobileQuickNote.swift:113-116: "no refusal here is ever reached by a road that discarded her text"). The finding's secondary 13p store-re-lock sub-case is weaker than claimed — a lock tears down the whole `.ready` subtree the sheet lives in — but the sealed road alone carries it.

---

### P5. promotePicks copies an ARCHIVED pick as a block's ONLY take — I10 violated at birth, and the copied text is not what the column showed

`Sources/VariorumCore/Operations/Operations+Versions.swift:674`

**MAJOR** · CONFIRMED · invariant-violation · lens: ops: structural core · confidence 0.85

**Mechanism**

copyPlacements' fan read (:663) has NO status filter, so an archived take is in `fan`; `lensShown = chosenPicks?[block.id].flatMap { fan.first { $0.id == pick } }` (:674) therefore RESOLVES an archived pick, and with `carryFans: false` `toCopy = [shownVariant]` (:683) makes it the copy's only take. `copyFan` preserves status verbatim (`status: take.status`, Operations+Variant.swift:374), and both `chosenCopyID` and `defaultCopyID` (:710-717) land on that one archived copy. Concrete path: on the Takes/Lenses board pick take T for block B into a scratch column (TakesViewModel.swift:853); archive T from the same board (TakesViewModel.swift:1171 — `ensureNotLastActive` permits it whenever B has another active take); scratch picks are never pruned, so the column silently falls through to B's chosen take (resolvedTake, TakesViewModel.swift:487-499); then ⧉ 'Make this a note' → 'New note, only what this column shows' (LensesBoardView.swift:707) → promoteColumn(carryFans:false) → promotePicks (TakesViewModel.swift:955). RESULT: the new note holds a LIVE, PLACED block whose single variant is status='archived' — zero live active variants (I10). The block still renders (Queries.renderPost's `dflt` join deliberately omits the active check, PostRender.swift:155-157) but every keystroke refuses: autosave → editableVariant throws `archivedVariant` (Operations+Variant.swift:317-321). And the text is wrong: the column was displaying B's chosen take, while the copy carries the archived pick's prose — a door labelled 'only what this column shows' produces different words. `divide` on that block then reads activeVariants == 0 and refuses with `fannedBlock` (Operations+Structural.swift:200), naming a fan that is not there. `promoteLens` is immune because Queries.effectiveLensSelection joins `AND v.status = 'active'` (LensQueries.swift:55-59); the sibling door adoptPicksPreservingChosen validates `take.status == .active` explicitly (Operations+Versions.swift:361-365) — promotePicks alone does not.

**Evidence**

> Operations+Versions.swift:663 `SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id` (no status filter) · :674 `let lensShown = chosenPicks?[block.id].flatMap { pick in fan.first { $0.id == pick } }` · :683 `toCopy = [shownVariant]` · Operations+Variant.swift:374 `workingText: take.workingText, status: take.status,` · contrast Operations+Versions.swift:363 `take.blockId == block.id, take.deletedAt == nil, take.status == .active` (adoptPicksPreservingChosen validates; promotePicks does not) · the doc-claim it breaks, Operations+Versions.swift:387 `/// picks overlaying the source's chosen ... A pick naming a take that isn't live on its block falls through harmlessly` — an archived take IS live (deleted_at IS NULL), so only the tombstoned/foreign case falls through. The only test of that claim uses a nonexistent id at default carryFans:true (Tests/VariorumCoreTests/VersionOperationsTests.swift:366 `promotePicks(post: w.postID, picks: [w.block1: "no-such-take"])`), so the archived + carryFans:false combination is unpinned.

**Why it matters**

A promoted note is born structurally corrupt (I10) and unwritable: the block shows prose she cannot edit, with no fan on any Takes surface to unarchive from, and the prose is not the prose the door promised. Both the ops-layer defect and the missing pick validation sit one guard line away from the sibling door that already does it right.

**Verifier**

Traced every leg in source. (1) Operations+Versions.swift:663-670 fetches the fan with `WHERE block_id = ? AND deleted_at IS NULL` — no status filter, so archived takes are in `fan`; :673-675 `lensShown = chosenPicks?[block.id].flatMap { pick in fan.first { $0.id == pick } }` therefore resolves an archived pick, and :681-684 `toCopy = [shownVariant]` under carryFans:false makes it the sole copied take. (2) copyFan (Operations+Variant.swift:373-379) copies `status: take.status` verbatim, and :709-717 land BOTH chosenCopyID (from sourceChosenID == the pick) and defaultCopyID (block.defaultVariantId not in the copied set ⇒ falls to shownVariant's copy) on that archived copy ⇒ a live, placed block with zero live ACTIVE variants (I10 as the ops layer enforces it — cf. archiveVariant's ensureNotLastActive, Operations+Deletion.swift:43). (3) copyPost (:583-601) performs no pick validation, so nothing upstream filters. (4) The caller path is real and reachable: TakesViewModel.pick (:745-752, scratch case) and adoptMintIntoColumn (:850-854) write scratch picks with no status re-check; archiveTake (:1171) → archiveVariant permits archiving whenever another active take exists; NOTHING prunes column.picks (all 16 `picks` sites checked — only :881 clears them, on save-as-lens); resolvedTake (:487-499) → PaneTextAuthority.resolvedText (:157-165) falls through to the slot's chosen because projection.fans is the live ACTIVE fan (TakesQueries.swift:13-16); promoteColumn's scratch arm (:947-957) passes the raw picks; the carryFans:false door exists (LensesBoardView.swift:707). (5) Consequences confirmed: PostRender.renderPost's `dflt` join deliberately omits the active check (PostRender.swift:155-157 + the doc at :116-120), so the block renders; autosave → editableVariant throws archivedVariant (Operations+Variant.swift:18, 317-321); divide reads activeVariants == 0 and throws fannedBlock (Operations+Structural.swift:192-200). (6) The asymmetry is real: promoteLens goes through effectiveLensSelection, which joins `AND v.status = 'active'` (LensQueries.swift:53-59), and adoptPicksPreservingChosen validates `take.status == .active` (Operations+Versions.swift:363-365); promotePicks alone does not. No test covers archived + carryFans:false (VersionOperationsTests.swift:366 uses a nonexistent id at the default carryFans:true), and I found no note in notes/ or in the code documenting this as an accepted consequence — the promotePicks docstring (:385-387) claims the opposite. ONE overstatement in the finding, which does not refute it: the copy's archived take IS reachable — TakesBoardView.swift:1113-1150 renders the per-block "archived · n" disclosure with an Unarchive button for any block that has a slot, so the note is not unrecoverable; the wrong-prose half and the I10-at-birth half stand.

---

### P6. restoreNoteVersion replaces a note's whole content without clearing the redo future, so a redo injects a block from the abandoned timeline into the restored note

`Sources/VariorumCore/Operations/Operations+NoteVersions.swift:187`

**MAJOR** · CONFIRMED · correctness · lens: undo/redo · confidence 0.85

**Mechanism**

The redo future is cleared ONLY inside UndoStack.register (redoEntries.removeAll() at UndoStack.swift:136); nothing else clears it (removeAll() has no production caller). restoreNoteVersion registers nothing — it self-classifies as "the recovery-door class" — yet it tombstones every live block of the note plus a purge intent each, and copies a fresh family in. Trace: (1) in note N holding A,B run merge(A,B) → A' minted, entry E registered; (2) press ⌥⌘Z → revertStructural tombstones A' at stamp t2 (its placement row cascades to the same stamp) and E moves onto redoEntries; (3) restoreNoteVersion(N, from: V) replaces the note's content and leaves redoEntries alone; (4) press ⇧⌥⌘Z → reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) reads block.deletedAt == t2, finds the container_block row WHERE block_id = ? AND deleted_at = t2, sees container N still live, revives it, then sets block.deletedAt = nil (:420) and flips the cascade victims (:423). A', holding merged text from the state she explicitly replaced, is resurrected into the restored note with no refusal and no message. The divide flavour wedges instead: restoringTexts names A's variant, which step 2 cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the reapply rolls back, and the entry stays on the redo stack forever (its target is purge-intent-fenced out of the tray, so the refusal is unresolvable) — and redo is strictly LIFO, so every entry beneath it is unreachable for the session. deleteContainer is the same root cause with a milder outcome (live unplaced block inside a tombstoned note). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 uses deleteBlock — a REGISTERING act — so it cannot catch this class.

**Evidence**

> UndoStack.swift:130-139 — `let collected: Bool = lock.withLock { nextID += 1; let entry = Entry(...); redoEntries.removeAll()` (the only clear site). Operations+NoteVersions.swift:176 — `/// **NO undo entry** (the recovery-door class, with \`restoreReading\` and /// \`restoreSection\` as the precedent)`. Operations+UndoInverses.swift:420-423 — `block.deletedAt = nil` … `try flipBlockCascadeTombstones(db, blockID: minted.blockID, stamp: stamp, now: now)`. UndoStack.swift doc: "**any new structural act clears the redo stack** — the standard discipline: once the timeline forks, the abandoned future is gone."

**Why it matters**

Canon (CLAUDE.md / AppSpec §9 / UndoStack's own contract) states that any new structural act clears the redo future precisely so an abandoned timeline can never be re-applied. A version restore is the most content-destructive act in the app, and it forks the timeline maximally; a redo after it either puts pre-restore prose back into the note she just restored (silent wrong content in her real writing) or permanently wedges the redo stack for the session.

**Verifier**

Traced end to end in source. redoEntries is cleared ONLY at UndoStack.swift:136 (inside register) and :276 (undoing past a redo:nil entry); removeAll() at :304 has no production caller (grep over Sources+App finds only test callers). restoreNoteVersion (Operations+NoteVersions.swift:187) registers nothing — its doc self-classifies as "the recovery-door class" at :176 — yet step 2 (:218-234) tombstones every live placement's block and mints a purge intent per block, and step 3 copies a fresh family in. Its only door, VersionActs.restore (App/Variorum/Shared/VersionActs.swift:40-48), adds no stack handling. Merge's registration (Operations+Structural.swift:747-754) passes restoringTexts: [] for redo, so reapplyStructural's untombstoningBlocks loop (:404-424) hits nothing that can refuse: the minted block's placement row still carries the undo's stamp, container N is live and unlocked, so ensureUnlocked passes, block.deletedAt = nil at :420 and flipBlockCascadeTombstones at :423 — the merged block is resurrected into the note whose content was just replaced. The divide flavour's wedge is equally real: its redo carries restoringTexts: [sourcePreImage] (:246-249) on a variant the restore's Delete Now road cascade-tombstoned, so liveVariant (Operations.swift:78) throws variantNotFound, the whole reapplyStructural transaction rolls back, and UndoStack.redo (:296-303) leaves the entry on redoEntries — strictly LIFO, so the session's redo stack is unreachable thereafter, and no user door can void the fencing intent (PoolAndTray.swift:107-109 / Trash.swift:169 hide the target). Not documented as accepted: notes/plans/post-13l-polish-round.md contains no occurrence of "redo" at all, and AppSpec §9 + OverallModel §3 + UndoStack's own header all state the contrary rule ("any new structural act clears the redo future"). RedoStackTests.anyNewStructuralActClearsTheRedoFuture:440 does use deleteBlock, a registering act, so it cannot cover this class. deleteContainer (Operations+Container.swift:383) is confirmed to register nothing either, the same root with the milder outcome. Severity held at MAJOR: the road is narrow (structural op → undo → version restore → redo) but the outcome is silent wrong prose in a live note, plus a session-permanent redo wedge, against an explicitly canonized contract.

---

### P7. The boards' branch / "＋ new take" / ⌘T doors copy the STORE past a dirty buffer — the Write editor's identical gesture flushes first

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1047`

**MAJOR** · CONFIRMED · correctness · lens: Mac takes/compare/canvas · confidence 0.90

**Mechanism**

A live take pane on the Takes board is buffer-authoritative: each keystroke goes to `authority.bufferEdited` + `autosave.record`, and `AutosaveCoordinator`'s debounce is 500 ms (AutosaveCoordinator.swift:95), so the `variant` row lags the screen for up to half a second. ⌘T is bound to `.newTake` (EditorCommands.swift:153) and the board's routed handler hands the LIVE pane straight to the branch door: TakesBoardView.swift:330 `case .branch: guard let pane = model.focusedPane ... await model.branchTakeRevealed(blockID: pane.blockID, from: pane.variantID, ...)` → `branchTakeRevealed` (TakesViewModel.swift:2002) → `branchTake` (:1047) → bare `session.runner.run { ops in try ops.branchVariant(...) }`. No link in that chain flushes. `branchVariant` copies the source's ROW text inside the transaction (Operations+Variant.swift:196, `text: source.workingText`). Concrete sequence: pane shows "…and then she left."; she types " Or did she?" (pending[V] set, unflushed); within 500 ms she presses ⌘T; the minted take is a copy of "…and then she left." without the new sentence; the ring then moves onto the new card and she keeps writing there, so the two takes permanently diverge on text she never chose to drop. This contradicts OverallModel §3 ("Branching a variant INHERITS the current buffer's text") and the app's own flush-first doctrine — `AppSession.runCopying` (AppSession.swift:316) exists for exactly this hazard ("the copying operations read `working_text` ROWS, so a copy taken inside the editor's autosave debounce lacks the last seconds of typing"), and the Write editor's twin gesture `EditorViewModel.mintCaretTake` (EditorViewModel.swift:2363) does `await autosave.flushNow()` before `ops.branchVariant`. Same-class siblings on the same bare `runner.run`: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) — the Lenses diverge-here door; `addWriteColumn` (:625), `replaceColumnWithNewWrite` (:672) and `writeNewTakesEverywhere` (:989), which call `ops.branchAllFans(post:)` and mint a per-block branch from `shown.workingText` (Operations+Versions.swift:474); and `WriteTakesPanel.swift:238`, whose branch button shares the Write editor's coordinator. Every neighbouring board door — `copyAllTakes`, `moveTake`, `mergeSelectedBlocks`, `commitFocusedTake`, `duplicateAsVersion`/`promoteColumn` via `runCopying` — flushes first, so one gesture behaves two ways depending on which surface it is pressed from.

**Evidence**

> TakesViewModel.swift:1047-1057 — `func branchTake(blockID: String, from variantID: String) async -> Variant? { status = nil; do { return try await session.runner.run { ops in try ops.branchVariant(blockID, from: variantID) } }` (no flush). Operations+Variant.swift:195-199 — `return (text: source.workingText, parent: source.id, fanPosition: ...)`. Contrast EditorViewModel.swift:2363-2375 — `Task { await autosave.flushNow(); ... take = try ops.branchVariant(blockID, from: sourceID) }`. Contrast AppSession.swift:316-320 — `func runCopying<T>(from postID: String, ...) { await flushExistingAutosave(forPost: postID); return try await runner.run(body) }`, whose doc names "THE COPY FAMILY'S ONE ENTRY (13e E10 — the KnownIssues row 'Copy doors read the store past a dirty buffer', owner 13e)".

**Why it matters**

A branch is the app's single most-used take gesture and its whole promise is "start from what I'm looking at". Copying the row instead of the buffer silently drops the last seconds of writing from the copy, on a keyboard chord, on the surface whose panes are live editors — and the doctrine, the entry point (`runCopying`) and the correct sibling implementation all already exist, so this is unfinished sweep rather than an open design question. The KnownIssues row that owned the class was retired at 13e's closeout, so the residue is currently unowned.

**Verifier**

Traced end to end. TakesBoardView.swift:330 `.branch` → `model.branchTakeRevealed(blockID:from:preferredColumnID:)` (TakesViewModel:2002) → `.takes` arm → `branchTake` (:1047) = `session.runner.run { try ops.branchVariant(...) }` with no flush anywhere in the chain; `Operations+Variant.swift:195` returns `text: source.workingText` (the ROW). Panes are genuinely buffer-authoritative and lag the store: `paneEdited` (:567-576) does `authority.bufferEdited` + `autosave.record`, and AutosaveCoordinator.swift:96 defaults `debounce: .milliseconds(500)`. `revealTake` → `focus()` only flushes AFTER the branch has already read the stale row (:530-531), so the source keeps her text and the COPY is what loses it. The correct sibling exists: `EditorViewModel.mintCaretTake` (:2363-2374) awaits `autosave.flushNow()` before `ops.branchVariant`, so the same ⌘T behaves two ways. Not a documented exemption: the 13e E10 sweep table (notes/plans/phase-13e-takes-block-management.md:2843) is explicitly headed "every door that mints a copy from stored text" and lists only duplicateAsVersion/promoteLens/promotePicks/MembershipChip/divergeForBook/poolDrop — no branchVariant door appears, and the `runCopying` doc's stated reason (:2165-2168) is only that non-copy doors shouldn't pay; branch mints a copy. Strong corroboration that the project treats this as a defect, not a tradeoff: the phone's `branchDisplayed` (MobileTakesBrowser.swift:330-350) flushes first with a comment naming the identical mechanism, landed as a Stage-2-ladder MAJOR (mobile-app-plan.md:2803, :2947). Siblings verified live too: `branchIntoColumn` (:794) and `blankIntoColumn` (:823) are bare `runner.run`; `writeNewTakesEverywhere` (:989) calls `ops.branchAllFans(post:)` on the bare runner. Severity stays MAJOR: wrong content in the copy on a common keyboard road; the original's text is not lost (its flush lands), so it is not BLOCKER-class.

---

### P8. A purge expands the family from the local store only, so a peer row above the purging device's cursor is left on the mirror pointing at a container purged everywhere — a permanent, unrecoverable pull stall

`Sources/VariorumCore/Sync/PurgeJanitor.swift:175`

**MAJOR** · PLAUSIBLE · sync-correctness · lens: sync engine · confidence 0.50

**Mechanism**

PurgeJanitor.sweep() expands a purge family with `PurgeFamily.expand(db, roots: [root])` against the LOCAL store and hands exactly `expansion.orderedRows` to `transport.executePurge`; the server 'deletes EXACTLY the rows it is handed' with no orphan check (10_phase13j_purge.sql, sync_purge_execute). The horizon that gates eligibility is `min(transport.syncHorizon(...), cursor)` (PurgeJanitor.swift:114), and the device's own cursor sits at head-minus-the-A5-visibility-band (`server_written_at <= clock_timestamp() - interval '2 seconds'`, 10_phase13j_purge.sql:443/455) — so rows written on another device in the last ~2s exist on the mirror and are ABOVE this device's cursor when the sweep runs (the sweep is the round's last step, after pull and push). The intent road has no 30-day gate: collectRoots (PurgeJanitor.swift:318-340) makes a live intent eligible on `s.server_seq <= :horizon` alone. Concrete sequence: phone B creates block X inside note N offline; Mac A deletes N and Delete-Now's it; both devices pull the intent (that is what makes it horizon-eligible); B's next round applies N's tombstone — the container cascade tombstones X and its container_block row with N's exact stamp — and then PUSHES X plus its placement, landing above A's cursor if the push commits inside the visibility band; A's sweep in that same window expands N's family from A's store, which has never seen X, and purges only what it knows. The mirror keeps X's container_block row referencing a container that has been physically deleted from the mirror and from every device. No ledger entry names it (sync_purge_execute ledgers only what it was handed), and nothing re-collects it: reconcileLedger (PurgeJanitor.swift:277-291) expands the ledger roots on B and physically removes X locally there too, so no device holds a tombstone for it. A's next pull delivers that placement row; SyncEngine.foreignKeysSatisfiable resolves `container_block.container_id` -> `container` N, which exists neither locally nor in the arriving batch, so it returns false, stopIndex truncates, and the cursor holds forever — N can never arrive. Tombstoned rows get no exemption: the FK walk runs on every row regardless of deleted_at.

**Evidence**

> PurgeJanitor.swift:138-141 — `let family = try PurgeFamily.expand(db, roots: [root])` / `return (family, try Self.familyVerdict(db, family, horizon: horizon, road: .transported))`; :175-176 — `let grantedSeq = try await transport.executePurge(expansion.orderedRows, activeKeyID: keyID)`.  PurgeJanitor.swift:114 — `let horizon = min(try await transport.syncHorizon(activeKeyID: keyID), cursor)`.  SyncEngine.swift:507-513 — `if arriving[fk.targetTable]?.contains(target) == true { continue }` / `let exists = try Bool.fetchOne(db, sql: "SELECT EXISTS (SELECT 1 FROM \(fk.targetTable) WHERE \(fk.targetPrimaryKey) = ?)", arguments: [target]) ?? false` / `guard exists else { return false }`.  10_phase13j_purge.sql sync_purge_execute — `execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk) using item->>'row_id', caller;` with no family verification.

**Why it matters**

S2's one bent clause (OverallModel §6, the 13j memo §4f) is safe only if 'a tombstone may be physically removed only after every live device has seen the deletion'. The horizon proves every device saw the INTENT; it proves nothing about rows those devices pushed afterwards, and the purging device's own cursor is deliberately behind head by the A5 margin. The result is the exact poison row SyncSpec §5's straggler tolerance cannot heal — the referent is gone from the mirror, so no later batch completes it — and combined with the discarded `stalled` flag the device stops integrating anything from the account while continuing to report clean rounds. The memo records the never-pushed-child variant (ladder B, B2) and closes it via the reconcileLedger pre-pass; the already-pushed-child variant is the mirror image and is not covered by that fix.

**Verifier**

Every code link checks out and no guard covers the case. (1) Repairs.swift:505-577 `enqueueSuppressedCascadeVictims` explicitly enqueues container_block/block/variant rows on a live→dead container transition applied from a pull — so a peer that has JUST learned the note is dead is REQUIRED by SyncSpec §7 direction (1) to push rows of that dead family, which directly contradicts the memo §2 premise "no peer can re-push them because no peer still believes the thing is live". (2) PurgeJanitor.sweep :138 expands with `PurgeFamily.expand(db, roots:[root])` against the LOCAL store and hands `expansion.orderedRows` to executePurge; PurgeFamily.expandContainer (:104-125) can only see rows this device holds. (3) 10_phase13j_purge.sql sync_purge_execute is exactly as quoted — `delete from %I where owner_id=$2 and %I=$1` per handed item, ledgering only what it was handed, no orphan check; the 'purged' push refusal keys on the row's OWN id, which the purging device never knew. (4) SyncEngine.foreignKeysSatisfiable (:503-515) introspects FKs from the live schema and has NO deleted_at exemption, so an arriving container_block whose container is neither local nor in-batch truncates the batch and holds the cursor — permanently, since the referent is gone from the mirror. (5) reconcileLedger (:277-291) expands the ledger roots and deleteLocal's them on the peer, removing the child LOCALLY only; nothing ever removes it from the mirror, and no device retains a root to re-collect it. The B2 fix and its pin `aReturnersUnpushedChildNeverLandsAsAMirrorOrphan` cover only the never-pushed variant, as the finding says. WHY PLAUSIBLE AND NOT CONFIRMED — one narrowing fact the finding understates: SyncEngine.pull sends `deviceID` only on the first window, where `since` is the PRE-pull committed cursor, so the peer's device_cursor (and hence the horizon) rises only on its NEXT pull — one full round after it pushed the child. By then the child is normally already visible and the purging device's own pull integrates it into the family, closing the hole. The orphan survives only inside the A5 visibility band (10_phase13j_purge.sql:443/455, `server_written_at <= clock_timestamp() - interval '2 seconds'`) or the pull→sweep gap, i.e. a ~2 s cross-device interleaving. That window is genuine, not hypothetical — FakeSyncServer already models it (`visibilityHorizon`, `holdPushes`/`commitHeldPushes` at :109-153, built for the A5 skew), so a deterministic repro is constructible: hold B's push, let A pull + sweep, release. Whether it is reachable in her real two-device use is a timing question I cannot settle by reading. Severity kept MAJOR: the outcome is a permanent one-way inbound jam (silent, given finding 1) recoverable only by re-onboard, and it falsifies a stated safety premise of the bent-S2 design — but no data is lost locally and the trigger is race-gated.

---

### P9. expandContainer's member-block arm is liveness-conditional, so expanding a LIVE container purges the note and its placements while orphaning every block it held

`Sources/VariorumCore/Sync/PurgeFamily.swift:118`

**MINOR** · CONFIRMED · invariant-violation · lens: purge & trash · confidence 0.50

**Mechanism**

PurgeFamily.expandContainer picks up member blocks with `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at` (PurgeFamily.swift:112-118). If the container row is LIVE, c.deleted_at is NULL and the equality is never true, so the expansion returns ZERO blocks — while the rest of expandContainer still takes all of container_block, lens, lens_choice, canvas_layout, reference, post_tag and reading_post for that container. The one call site that can hand it a live container root is the push path's ledger refusal, SyncEngine.swift:157-176, which expands from the pushed row with no liveness precondition: `let family = try PurgeFamily.expand(db, roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)]); try PurgeFamily.deleteLocal(...)`. Outcome on that path: the container row, its placements and its side rows are physically deleted; its blocks and variants stay LIVE, unplaced, and with last_container_id NULLed by deleteLocal's own detachment arm — the same zero-surface state as Finding 1, and permanently unpurgeable afterwards (a live row is never a tombstone root, and joinStrandedOriginals only reaches ancestors of family blocks). PRECONDITION, stated honestly: reconcileLedger normally screens this safely because a peer's executePurge ledgers EVERY family row, so the blocks arrive as roots of their own; reaching the live-container case needs the ledger scan point to have skipped that peer's entries — which the code itself records as possible (PurgeJanitor.swift:117-122, B9) — plus the row being live locally after a Put back. The reportable part is that B9's stated mitigation does not cover it: "those families re-collect through the 30-day road" is false for a LIVE container, which has no tombstone to re-collect.

**Evidence**

> PurgeFamily.swift:112-119 — `SELECT DISTINCT b.id FROM block b JOIN container_block cb ON cb.block_id = b.id AND cb.container_id = ? JOIN container c ON c.id = ? WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at`. SyncEngine.swift:169-175 — `let family = try PurgeFamily.expand(db, roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)])` / `try PurgeFamily.deleteLocal(db, family: family, stamp: nowStamp(), enqueue: ...)`. PurgeJanitor.swift:117-122 — "the scan point is a SELF-ECHO device, not a completeness guarantee — a concurrent peer sweep's lower-seq entries may be skipped by this advance; those families re-collect through the 30-day road and converge there."

**Why it matters**

PurgeFamily's own header states the contract this breaks: "the FK CLOSURE under each root, which is exactly what 'family-completeness leaves ZERO orphan rows' means mechanically." A partial expansion here leaves her prose alive on disk with no note, no placement and no home pointer — invisible on every surface (the global unplaced listing was removed as a user surface by her J6 ruling) and never reachable by any later purge, so it neither survives usefully nor goes away.

**Verifier**

The SQL claim is exact and I re-read it: PurgeFamily.swift:112-120 selects member blocks `WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at`, so a LIVE container root yields zero blocks while lens/lens_choice/canvas_layout/reference/post_tag/reading_post AND every container_block row (collected by container_id, liveness-blind) still enter the family. deleteLocal then removes them; the surviving blocks/variants keep living, their last_container_id NULLed by the detachment arm, unplaced — invisible (the global unplaced listing is debug-only since J6) and unreachable by any later purge (a live row is never a tombstone root; joinStrandedOriginals returns immediately on an empty familyBlocks set). No FK failure catches it, because block→container is the nullable last_container_id that deleteLocal pre-nulls. I verified no call site guards liveness on the engine's `.purged` handler (SyncEngine.swift:169-175) or on reconcileLedger (PurgeJanitor.swift:~285, which filters only on rowExists). The finding's own cited road is weaker than it thinks and it says so honestly — a peer's executePurge ledgers EVERY family row, so the blocks are usually refused 'purged' as their own roots in the same push loop and self-heal. But a MORE reachable road it did not find strengthens it: PurgeJanitor.swift:179-186 re-expands inside the removal's own transaction AFTER executePurge, with no second verdict, and its own comment rules "a restore that raced the await loses to the purge" — a Put back landing in that network window makes the root live, so the note and its placements go while the just-revived blocks stay live and orphaned. familyVerdict's .stale check (PurgeJanitor.swift:441-447) closes the collection-time case but not this one. Contradicts PurgeFamily's own header contract ("purge is never partial"; the FK-closure argument does not cover the nullable pointer) and B9's stated mitigation ("re-collect through the 30-day road") is indeed false for a live row. Severity MINOR is right: deep race/skip preconditions, no crash or corruption, and the prose survives on disk — it just goes invisible.

---

### P10. ProtectionController.setPassphrase writes a stale envelope over a recovery wrap landed during its KDF — the shown twelve words stop opening the library

`App/Variorum/Shared/ProtectionController.swift:177`

**MINOR** · CONFIRMED · data-loss · lens: concurrency & threading · confidence 0.55

**Mechanism**

`setPassphrase` reads the whole envelope from disk at :180, suspends in the detached Argon2id derivation at :183 (hundreds of ms by construction), then writes the WHOLE file back at :189 with no version/fingerprint check. `generateAndLandRecoveryPhrase` (:258-275) has NO await between its own read (:265) and write (:267), so it completes entirely inside that window. Reachable across two windows over the ONE controller: `ProtectionNoticeBar` is mounted on the MAIN window (VariorumApp.swift:104-106) over `bootstrap.protection`, while the set sheet is presented in the SETTINGS window, and a macOS `.sheet` is window-modal, so the main window's nudge bar stays clickable. Trace: (1) Settings set-sheet, tap Set — reads envelope E0 (no wraps), suspends in the KDF; (2) main-window nudge bar → "take the recovery phrase" (ProtectionPane.swift:565-578 → PhraseOffer.take → generateAndLandRecoveryPhrase) reads E0, writes E1 = E0 + recoveryWrap, and the twelve words are displayed via PhraseOnlySheet for the user to write down; (3) the KDF returns and line 189 writes E2 = E0 + passphraseWrap — E1 is overwritten and the recovery wrap is gone from disk.

**Evidence**

> ProtectionController.swift:180-189 — `var envelope = ensuredEnvelope(for: key).envelope` ... `envelope = try await Task.detached(priority: .userInitiated) { [envelope] ... try updated.setPassphraseWrap(key: key, passphrase: passphrase, kdf: kdf); return updated }.value` ... `try saveEnvelope(envelope)`. ProtectionController.swift:264-267 — `let words = try RecoveryPhrase.generate(); var envelope = ensuredEnvelope(for: key).envelope; try envelope.setRecoveryWrap(key: key, words: words); try saveEnvelope(envelope)`. VariorumApp.swift:104-106 — `.safeAreaInset(edge: .bottom, spacing: 0) { ProtectionNoticeBar(controller: bootstrap.protection, services: services) }`.

**Why it matters**

The user is left holding twelve written-down words that no longer unwrap the store key, while `refreshEnvelopeFacts()` immediately sets `hasRecoveryWrap = false`, so the pane and the sheet contradict each other. Under R13p-4 the recovery phrase is one of only two roads back into an encrypted library. The same unversioned read-modify-write shape sits in `landRecoveryWrap` (:285-287), `setEscrow` (:360-369) and the genuinely parallel off-main `reconcileEscrowOffMain` (:488-493) — only `setPassphrase` has a long enough window today. Scoped MINOR rather than MAJOR deliberately: the mechanism is certain in the code, but reachability needs two protection surfaces touched within one KDF window.

**Verifier**

Mechanism verified exactly as quoted. ProtectionController.swift:177-190: `var envelope = ensuredEnvelope(for: key).envelope` is read BEFORE `try await Task.detached { ... setPassphraseWrap ... }.value`, then `try saveEnvelope(envelope)` writes the WHOLE envelope back. `saveEnvelope` (:134-137) is a straight `gate.saveEnvelope(...)` — no merge, no version/fingerprint check, no reload. `generateAndLandRecoveryPhrase` (:258-275) reads and writes with zero awaits between, so it completes atomically inside that window and is then clobbered. Reachability verified rather than assumed: VariorumApp.swift:104-106 mounts `ProtectionNoticeBar(controller: bootstrap.protection)` on the MAIN window and :239-243 hands the SAME `bootstrap.protection` to the Settings window's pane, and the pane presents its own set sheet at ProtectionPane.swift:185 — a macOS sheet is window-modal, so the main window's nudge stays clickable. The nudge's phrase button (ProtectionPane.swift:565-578) routes through `PhraseOffer.take` (PassphraseSetModel.swift:262-273) straight into `generateAndLandRecoveryPhrase`, and neither road consults `controller.busy`. Nothing in the file, CLAUDE.md, or notes/ documents a single-writer assumption for the envelope. Two things keep this MINOR and no higher, both of which the finding states honestly: the window is one Argon2id derivation (~hundreds of ms), and it needs a deliberate click in the OTHER window inside it — a same-window nudge cannot do it, because the notice bar hosts both sheets itself and is covered while either is up.

---

### P11. Both production readers of the key sidecar discard `StoreKeyEnvelopeError.unreadable`, so the lobby dead-ends with a false cause and the set-screen then overwrites the recovery wrap

`App/Variorum/Shared/AppBootstrap.swift:438`

**MINOR** · CONFIRMED · crypto · lens: silent failures · confidence 0.85

**Mechanism**

`StoreKeyEnvelope.load` deliberately throws `.unreadable` for a file that exists but cannot be decoded, and its own doc states why: "reading corruption as absence would let a surface claim 'no passphrase is set' over a library that has one." Both callers do exactly that with `(try? gate.loadEnvelope(url)) ?? nil`. (a) AppBootstrap.swift:239-245 and the re-lock's lock() at :414-420 build LobbyFacts from the nil, so `passphraseOffered`/`recoveryOffered` are false; with `demand == .passphrase` nothing is offered, `StoreLobby.noRoadExists` is true, and the surface renders `ProtectionCopy.deadEnd` — "no passphrase or recovery phrase is on file beside the library" — over a sidecar that holds both. The correct sentence for this exact case already exists at StoreProtection.swift:476-483 and is unreachable at the lobby. (b) ProtectionController.ensuredEnvelope:165-169 returns a BLANK `StoreKeyEnvelope()` on the nil; `setPassphrase`:180-189 wraps the key into that blank and `saveEnvelope` writes it with `options: .atomic` (StoreKeyEnvelope.swift:221), overwriting the file on disk — so the `recovery` blob (her twelve written-down words) and the `storeID` that names the iCloud escrow item are destroyed with no word said. A FOREIGN sidecar is carefully MOVED aside (`setAsideEnvelope`, line 167) precisely so its wraps survive; an UNREADABLE one is obliterated.

**Evidence**

> AppBootstrap.swift:437-438 `let url = storeURL ?? URL(fileURLWithPath: "/dev/null")` / `return (try? gate.loadEnvelope(url)) ?? nil`; ProtectionController.swift:159 `(try? gate.loadEnvelope(storeURL ?? URL(fileURLWithPath: "/dev/null"))) ?? nil`; ProtectionController.swift:165-169 `if let existing = loadEnvelope(...) { if existing.belongs(to: key) { return (existing, true) }; gate.setAsideEnvelope(...) }` / `return (StoreKeyEnvelope(), false)`; StoreKeyEnvelope.swift:201-203 `/// A file that EXISTS but cannot be decoded throws 'unreadable' — reading corruption as absence would let a surface claim "no passphrase is set" over a library that has one.`

**Why it matters**

On the one screen whose stated job is to tell a locked-out user the truth about their own library, an unreadable key file produces a confidently wrong cause and no doors; and the road out of that state (set a passphrase) silently destroys the recovery-phrase wrap that was the last way in. The typed error and the exact correct sentence both already exist and are thrown away one line before use.

**Verifier**

Verified verbatim. StoreKeyEnvelope.load (:201-212) throws `.unreadable` for an existing-but-undecodable file with the exact doc the finding quotes, and BOTH production readers discard it: AppBootstrap's `loadedEnvelope` (:433-439) and ProtectionController's nonisolated `loadEnvelope` (:157-160), both `(try? gate.loadEnvelope(...)) ?? nil`. (a) The lobby facts built from that nil give passphraseOffered=false/recoveryOffered=false; under `.passphrase` demand biometryOffered is false by construction, so `noRoadExists` (StoreLaunchGate.swift:172) is true and StoreLockView.swift:40 renders `deadEnd`, whose passphrase arm says "no passphrase or recovery phrase is on file beside the library" — a false cause over a sidecar that has both. The correct sentence does exist unreachable at ProtectionCopy.message(for:) :476-483. The `loadedEnvelope` doc's justification ("the lobby's roads re-load and WORD that refusal") is true only when a road renders — StoreLaunchGate.envelopeRoad:268 does propagate and word it — so it is a documented ASSUMPTION that fails in exactly this case, not a documented tradeoff. (b) ensuredEnvelope (:162-170) returns a blank `StoreKeyEnvelope()` on the nil (no setAside, because nil never enters the foreign branch), and setPassphrase (:180-189) writes it through `write(at:)`/`.atomic` (StoreKeyEnvelope.swift:216-221) — an atomic rename over a file the app could not read but the directory lets it replace. Worse than the finding says: reconcileEscrowOffMain (:487-493) does the same `try? gate.saveEnvelope` automatically at every reconcile when the escrow dial is ON. The FOREIGN/UNREADABLE asymmetry the finding names is real (setAside is a move, never a delete). One correction: a NEWER-format envelope decodes fine (formatVersion is a plain Codable field; requireCurrentFormat only guards wrap/unwrap), so `.unreadable` means corruption or an IO/permission failure — which is why severity comes down: the destroyed wraps are only recoverable in the transiently-unreadable-but-intact case.

---

### P12. `StoreFilePresence.classify` reports an existing-but-unreadable store as `.absent`, silently downgrading the persisted at-open mode to Auto and authorizing a fresh key mint over an encrypted store

`Sources/VariorumCore/Persistence/StoreKey.swift:244`

**MINOR** · CONFIRMED · correctness · lens: crypto & key custody · confidence 0.75

**Mechanism**

`classify` has no `fileExists` check: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }`, so a present, ciphertext-filled store that cannot be opened or read (EACCES/EBUSY/EIO; also a zero-length file after a failed copy) answers `.absent`. `routeAndOpen` additionally maps a failed `defaultStoreURL()` to `.absent` (`storeURL.map(StoreFilePresence.classify(at:)) ?? .absent`, AppBootstrap.swift:222-224). Two irreversible things key off that answer: (1) `StoreLaunchRoute.resolve` returns `.openResettingModeToAuto` and `routeAndOpen` PERSISTS the downgrade — `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` (AppBootstrap.swift:233-235) — so a transient I/O error permanently drops the user out of Locked-down; (2) `resolveStoreKey` re-classifies, sees `.absent` with empty custody (the demanded modes deleted both Keychain items) and takes the MINT branch, saving a brand-new key as the Auto item (AppDatabase+Dependency.swift:136-144). The subsequent `AppDatabase.onDisk` then fails to decrypt the real file, and because that failure is not the typed `keyUnavailable` refusal, `failedOutcome` returns `.failed(error, recovery: nil)` (AppBootstrap.swift:278) — a doorless screen despite a wraps-bearing sidecar sitting beside the store. The bogus key is now persisted, so once the I/O condition clears, every later launch repeats the same doorless failure: `custody.load()` returns it, `resolveStoreKey` returns it unconditionally, the open fails again with `keyUnavailable == false`.

**Evidence**

> StoreKey.swift:243-249 — `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent } … guard let head = try? handle.read(upToCount: 16) else { return .absent }`; AppBootstrap.swift:228-236 — `case .openResettingModeToAuto: var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)`; AppDatabase+Dependency.swift:128-144 — `if let held = custody.load() { return held }; if presence == .encryptedOrUnknown { throw … keyUnavailable: true }; let minted = StoreKey.mint(); guard custody.save(minted) …`; StoreLaunchGate.swift:132-138 — the route's own comment: "the store was deleted out from under its gate".

**Why it matters**

An I/O hiccup silently and permanently weakens the user's chosen protection posture (Locked-down → Auto, written to defaults) and mints a key that then locks them out of their own encrypted library through the app's doors, with no route offered even though the recovery wraps are on disk one directory away. `classify` cannot distinguish "deleted" from "could not be read", and the route treats them identically.

**Verifier**

Code checks out exactly as quoted. StoreKey.swift:243-249: `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` and `guard let head = try? handle.read(upToCount: 16) else { return .absent }` — there is no `fileExists` check, so a present ciphertext store that cannot be opened for reading answers `.absent`. `StoreFilePresence`'s own doc (:225-226) says `.absent` means "No file (or an empty one)" — the unreadable case is undocumented, unlike the deleted-store case, which IS deliberate and documented (StoreLaunchGate.swift:129-138 and AppBootstrap.swift:228-236 both record it as PROVISIONAL). Both consequences trace: (1) `routeAndOpen` persists the downgrade via `gate.saveDials(dials, scope)` at :235; (2) `openStore` re-classifies at AppDatabase+Dependency.swift:98 and `resolveStoreKey` (:123-143) skips the `keyUnavailable` refusal, mints, and `custody.save(minted)` persists the bogus key — after which the subsequent `AppDatabase.onDisk` failure is NOT typed `keyUnavailable`, so `failedOutcome` (AppBootstrap.swift:278) returns `recovery: nil` and the wraps-bearing sidecar beside the store is never offered, permanently, on every later launch. SEVERITY CORRECTED DOWN to MINOR: the trigger requires a store file that is present, non-empty, and unreadable via FileHandle (broken ownership/permissions after a hand restore is the plausible instance) — narrow. Note the sharp edge is the persisted mint, not the mode downgrade: it converts a recoverable state into a doorless one that survives the I/O condition clearing.

---

### P13. StoreFilePresence.classify reports an unreadable store file as `.absent`, disabling the at-open gate and defeating the never-mint-over-ciphertext refusal

`Sources/VariorumCore/Persistence/StoreKey.swift:244`

**MINOR** · CONFIRMED · crypto · lens: silent failures · confidence 0.70

**Mechanism**

`classify` maps every FileHandle open/read failure (EACCES, EMFILE on fd exhaustion, EIO, an unsatisfied iOS data-protection class) onto `.absent`, which is indistinguishable from "no store here". Two consumers treat `.absent` as authorization. (a) AppBootstrap.swift:222-224 feeds it to `StoreLaunchRoute.resolve`, whose `guard presence != .absent else { return .openResettingModeToAuto }` (StoreLaunchGate.swift:143) makes AppBootstrap.swift:228-235 **persist** `dials.mode = .auto` via `gate.saveDials` — one unreadable moment permanently turns off her Biometric/Passphrase-at-open gate with nothing said. (`storeURL == nil`, i.e. `defaultStoreURL()` throwing, reaches the same `?? .absent` and the same persisted downgrade.) (b) AppDatabase+Dependency.swift:125-145 skips its `presence == .encryptedOrUnknown` refusal, mints a fresh StoreKey and SAVES it into the Keychain before `AppDatabase.onDisk` fails against the real ciphertext with a generic SQLCipher error (`keyUnavailable == false`). Passphrase mode deletes both Keychain items by design (ProtectionController.swift:330-333), so "encrypted store + empty custody" is its normal steady state — precisely where this fires. On the next launch `custody.load()` returns the bogus key at line 128, `presence` is never consulted again, and AppBootstrap.failedOutcome's `guard error.keyUnavailable` (line 275) can never build the sidecar-unlock recovery road: a doorless dead end over a library whose variorum-keys.json is right beside it.

**Evidence**

> StoreKey.swift:244 `guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }` / :246 `guard let head = try? handle.read(upToCount: 16) else { return .absent }` — then AppDatabase+Dependency.swift:128-137 `if let held = custody.load() { return held }` / `if presence == .encryptedOrUnknown { throw StoreOpenError(... keyUnavailable: true) }` / `let minted = StoreKey.mint()` / `guard custody.save(minted) else { ... }`; and StoreLaunchGate.swift:143 `guard presence != .absent else { return .openResettingModeToAuto }` with AppBootstrap.swift:233-235 `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)`

**Why it matters**

A transient I/O failure silently downgrades the whole R13p-5 at-open protection to Auto and persists it, and can write a wrong key into custody that permanently suppresses the R1-M3 sidecar-present unlock road — turning a recoverable encrypted library into a dead end. The refusal these guards exist to make is derived from a read that cannot distinguish "absent" from "could not be read".

**Verifier**

Traced both consumers in real source (the only two non-test call sites). StoreKey.swift:243-249 does map every FileHandle-open/read failure to `.absent`, and the enum's own doc only claims `.absent` means "No file (or an empty one)". (a) AppBootstrap.swift:220-235 feeds it to StoreLaunchRoute.resolve (StoreLaunchGate.swift:139-143: `guard presence != .absent else { return .openResettingModeToAuto }`) and that case does `var dials = dials; dials.mode = .auto; gate.saveDials(dials, scope)` — a persisted downgrade of the R13p-5 gate with no sentence at the moment it happens. `storeURL == nil` reaches the same `?? .absent`. (b) AppDatabase+Dependency.swift:124-146 is exactly as quoted: `custody.load()` first, then the `presence == .encryptedOrUnknown` refusal (keyUnavailable: true), then mint + `custody.save`. And ProtectionController.setMode (:331-333) does delete BOTH Keychain items under `.passphrase`, so encrypted-store-with-empty-custody is that mode's steady state — the exact state where the mint fires. Once a bogus key is in custody, `custody.load()` short-circuits before presence is consulted again and AppBootstrap.failedOutcome (:275) requires `error.keyUnavailable`, so the sidecar-recovery road can no longer be built: the dead end is real. Nothing in the 13p plan or the code documents the absent/unreadable conflation (grep for 'classify' in the plan file returns nothing). Severity corrected DOWN: every leg is real, but the trigger is a filesystem/IO anomaly (EACCES after an oddly-permissioned restore, fd exhaustion, an iOS pre-first-unlock background launch under completeUntilFirstUserAuthentication), not an ordinary user road — real but narrow.

---

### P14. The quick note's `try?` folds a read failure into "There's nothing to save yet", orphans a note that WAS created, and lets the clock mint it a second time

`App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift:682`

**MINOR** · CONFIRMED · error-swallowing · lens: mobile app · confidence 0.70

**Mechanism**

`adopt` does `let blocks = (try? await session.database.read { try Queries.renderPost(db, containerID: containerID) }) ?? []` and then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { lastError = refusal(.emptyImport); saveState = .typing; return nil }`. The guard's comment argues unreachability from `importPost` alone ("it mints at least one block or throws") — but `try? … ?? []` converts a READ failure into the identical empty result, which that argument does not cover. Finding 1 supplies the reachable failure: `AppBootstrap.lock()` calls `binding.lock()` and closes the pool while this read can be in flight, after `importPost`'s write has already committed. Consequences, each traced: (a) she is shown "There's nothing to save yet." about a note that exists in SQLite; (b) `postID = containerID` on line 693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` passes on her next keystroke and `mintNow` runs `importPost` again — a second note with the same text, repeatably; (c) `variantID` stays nil, so `record(tail:)`'s `guard let variantID` returns and nothing she types afterwards is autosaved anywhere.

**Evidence**

> MobileQuickNote.swift:681-693 — `let blocks = (try? await session.database.read { db in try Queries.renderPost(db, containerID: containerID) }) ?? []` / `guard let owned = blocks.last, let ownedVariant = owned.variantID else { … lastError = MobileQuickNoteCopy.refusal(OperationError.emptyImport); saveState = .typing; return nil }` / `postID = containerID`. MobileQuickNote.swift:846-849 — `private func armMintClock() { guard clockTask == nil, postID == nil else { return } … }`.

**Why it matters**

The box's whole safety argument rests on knowing exactly which note and which variant it owns; a swallowed read turns "I could not confirm" into "nothing happened", which is the one answer that is false. Duplicate untitled notes in her library are also exactly the residue 13j's Trash work was cleaning up.

**Verifier**

The chain is exactly as described. MobileQuickNote.swift:681-691: `let blocks = (try? await session.database.read { … Queries.renderPost … }) ?? []`, then `guard let owned = blocks.last, let ownedVariant = owned.variantID else { … refusal(.emptyImport); saveState = .typing; return nil }` — and the guard's own justification ("Unreachable through `importPost` (it mints at least one block or throws)") argues only about the WRITE, so the `try? … ?? []` road is genuinely uncovered. Consequences verified: `postID = containerID` at :693 is never reached, so `armMintClock`'s `guard clockTask == nil, postID == nil` (:623-624) passes and the next keystroke's `handleTextChange` falls into `armMintClock()` (:497-500) → a second `importPost` with the same text; `variantID` stays nil so `record(tail:)`'s `guard let variantID` (:613) drops every later keystroke. Note the deliberate asymmetry the finding correctly implies: the sibling A1-19 arm DOES set `postID` first, so only this arm can double-mint. Reachability is the narrow part, which is why MINOR is right: it needs the pool to close between the committed write and the read — the `AppBootstrap.lock()` race (binding.lock() on a detached task) is the credible cause, while the file-protection cause the file's other comments name is unlikely after first unlock, since the store directory is deliberately `.completeUntilFirstUserAuthentication` (AppBootstrap.swift:491-501).

---

### P15. The raw 256-bit store key is embedded in SQL statement text, and GRDB puts the executed SQL into every error description — a failure renders the key on the store-failure screen and can persist it into UserDefaults

`Sources/VariorumCore/Persistence/AppDatabase.swift:116`

**MINOR** · CONFIRMED · crypto · lens: crypto & key custody · confidence 0.80

**Mechanism**

Two statements carry the key as a literal: `PRAGMA key = "x'<hex>'"` in `configuration(key:)`'s `prepareDatabase` (AppDatabase.swift:116, run on EVERY pool connection) and `ATTACH DATABASE ? AS encrypted KEY "x'<hex>'"` (StoreEncryptionMigration.swift:100). GRDB throws `DatabaseError(resultCode:message:sql:)` carrying that statement text (GRDB Statement.swift:440) and `DatabaseError.description` appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally (DatabaseError.swift:566-575; `trimmedSQLStatement` only trims whitespace/semicolons), with `errorUserInfo[NSLocalizedDescriptionKey] = description` (:621) so `localizedDescription` carries it too. GRDB's `publicStatementArguments` redaction protects arguments, not the SQL. Trace: a store whose one-time migration hits a throwing ATTACH (SQLITE_CANTOPEN on a full or read-only volume, an unwritable `.encrypting` temp, the attached-db limit) — the `do` block at StoreEncryptionMigration.swift:96-115 has no `catch`, so the DatabaseError escapes to `AppDatabase.openStore`'s generic arm, which does `StoreOpenError(storePath: url.path, reason: String(describing: error))` (AppDatabase+Dependency.swift:108); `StoreFailureView.swift:49` renders that as `Text(error.reason).textSelection(.enabled)` beside a "Reveal in Finder" button (mobile: MobileStoreFailureView.swift:51). Second path: `StoreBackup.integrityCheck` opens the copy with the KEYED artifact configuration and, on failure, returns `"could not be checked: \(error.localizedDescription)"` (StoreBackup.swift:417); that string becomes `BackupRunRecord.Leg.integrity`, is written to UserDefaults by `BackupLog.append`, and is rendered as a sentence at DataSafetyModel.swift:263/:279.

**Evidence**

> AppDatabase.swift:116 — `try db.execute(sql: "PRAGMA key = \"x'\(key.hexEncoded)'\"")`; StoreEncryptionMigration.swift:100 — `sql: "ATTACH DATABASE ? AS encrypted KEY \"x'\(key.hexEncoded)'\""`; GRDB/Core/DatabaseError.swift:571 — `if let sql { description += " - while executing `\(sql.trimmedSQLStatement)`" }`; AppDatabase+Dependency.swift:108 — `throw StoreOpenError(storePath: url.path, reason: String(describing: error))`; StoreFailureView.swift:49 — `Text(error.reason).textSelection(.enabled)`; StoreBackup.swift:417 — `return "could not be checked: \(error.localizedDescription)"`.

**Why it matters**

The whole-store key printed selectably next to the store's own path — on the one screen a user screenshots for support, and (via the backup log) written in cleartext into a UserDefaults plist that sits on the same disk as the ciphertext. It defeats at-rest encryption entirely for anyone who sees that string, and it is the precise leak `StoreKey.description`'s redaction ("a store key must never ride into a log line by way of an interpolation", StoreKey.swift:58-61) was written to prevent, one layer lower.

**Verifier**

The channel is real and undocumented. Verified: AppDatabase.swift:116 `try db.execute(sql: "PRAGMA key = \"x'\(key.hexEncoded)'\"")` and StoreEncryptionMigration.swift:100 `ATTACH DATABASE ? AS encrypted KEY \"x'\(key.hexEncoded)'\"` are the only two `hexEncoded` uses outside StoreKey itself. In the pinned checkout (.build/checkouts/GRDB.swift), `DatabaseError.description` at DatabaseError.swift:571 appends `" - while executing `\(sql.trimmedSQLStatement)`"` unconditionally, `errorUserInfo[NSLocalizedDescriptionKey] = description` at :620-622, and `Statement` constructs DatabaseError with `sql:` set. The migration's export block (StoreEncryptionMigration.swift:96-115) is a bare `do {}` with NO catch, so an ATTACH failure escapes uncaught to `openStore`'s generic arm, which does `String(describing: error)` into `StoreOpenError.reason` (AppDatabase+Dependency.swift:101-107), rendered as `Text(error.reason).textSelection(.enabled)` at StoreFailureView.swift:49. Nothing in notes/ or the 13p plan records this; StoreKey.swift:58-61's redaction shows the intent runs the other way. SEVERITY CORRECTED DOWN: the leak needs an error thrown BY one of the two key-bearing statements. `PRAGMA key` almost never errors (SQLCipher defers key validation to the first page read, so a wrong-key/corrupt store fails at `PRAGMA journal_mode`/the first SELECT, whose SQL carries no key), which also weakens the StoreBackup.integrityCheck path the finding cites — its realistic failures come from the fallback `PRAGMA integrity_check` read, not the key pragma. The one genuinely traceable road is a throwing ATTACH during the one-time plaintext migration (unwritable temp path, CANTOPEN, attached-db limit) — real, but a once-per-store road on a shrinking population. Worth fixing (bind the key as an argument, or catch-and-sanitize at both sites), at MINOR.

---

## T2 — P1 violations — cost that scales with the document

P1 is the one performance prohibition in the canon: cost proportional to viewport and edit, never to document or corpus size. Each of these is measured or traced to scale with N, and the first three are on the keystroke road.

### P16. StructuralGesturePlanner.seamPair is O(N^2) in block count and runs on every caret move and every keystroke (Mac)

`App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:419`

**MAJOR** · CONFIRMED · perf-p1 · lens: shared editor brain · confidence 0.90

**Mechanism**

BlockRangeIndex.range(ofEntryAt:) (BlockRangeIndex.swift:74-81) walks the entries from zero on every call. seamPair calls it inside `for i in 0..<max(0, index.entries.count - 1)`, so the loop costs sum(i) = N^2/2 additions — and for a caret anywhere OTHER than a block seam (i.e. essentially always) no `i` matches, so the loop runs to completion every time. Cadence, traced end to end: EditorView.textViewDidChangeSelection (EditorView.swift:583-585) -> model.updateCaretContext() (EditorViewModel.swift:2493) -> refreshGestureAvailability() called unconditionally at EditorViewModel.swift:2532 -> enabled(.mergeBlocks) -> StructuralGesturePlanner.plan(.mergeBlocks, …) -> merge(selection:world:) with selection.length == 0 -> seamPair. storageDidEdit also ends in updateCaretContext() (EditorViewModel.swift:1079), so it fires per keystroke as well as per arrow key. At the author's stated 100k-word bar (~1,400 paragraphs) that is ~980,000 main-actor inner iterations per caret move; at the 20,000 entries this repo's own perf pin adopts as its ceiling, ~2e8 — the same class as the twin CrossBlockEditPlanner.swift:141-153 records as measuring 23.8 s for one plan before it was fixed. The sibling separatorPair (line 407) has the identical shape on the same enablement road. Mac-only: the phone reaches the planner solely from an explicit gesture (MobileStructural.runSpanGesture:337-357), never from a caret change.

**Evidence**

> StructuralGesturePlanner.swift:417-421 — `private static func seamPair(atCaret caret: Int, index: BlockRangeIndex) -> (Int, Int)? {` / `for i in 0..<max(0, index.entries.count - 1) {` / `let separator = index.range(ofEntryAt: i).upperBound`. The accessor, BlockRangeIndex.swift:74-79 — `func range(ofEntryAt i: Int) -> NSRange { var location = 0; for (j, entry) in entries.enumerated() { if j == i { return … }; location += entry.length + 1 } }`. The false cost claim at the call site, EditorViewModel.swift:2529-2531 — `// Gesture enablement rides every caret/selection change … Cost: the caret block's boundary scan.`

**Why it matters**

P1 is the project's one hard prohibition — cost proportional to viewport and edit, never document size — and this sits on the caret/keystroke road unconditionally, which is the most protected road in the app. It is also worse than the twin already owned by 13u1 (planVisibleTakeEdit fires only on a cross-block edit; this fires on every arrow key). The call site's comment asserts the opposite cost, so a future reader has no reason to look. The same sweep found more sites of this class that no row names: EditorSurfaceController.swift:107 (applyDifferential, unconditional per-slot on every differential projection apply — the sync road), :2057 (find/replace, O(matches x N^2)), :1901/:1927, :2336 (DEBUG), ReadPostViewModel.swift:218/:297, and StructuralGesturePlanner.swift:407.

**Verifier**

Every link verified. BlockRangeIndex.range(ofEntryAt:) (BlockRangeIndex.swift:74-81) walks entries from zero on each call; seamPair (StructuralGesturePlanner.swift:417-425) calls it inside `for i in 0..<max(0, index.entries.count - 1)` with NO break, so a caret anywhere but a seam runs the full N^2/2. The cadence is unconditional: refreshGestureAvailability (EditorViewModel.swift:2015-2038) evaluates enabled(.mergeBlocks) as part of the GestureAvailability initializer -> plan(.mergeBlocks) -> merge(selection:world:) -> with selection.length == 0 -> seamPair (planner lines 345-352); updateCaretContext calls refreshGestureAvailability unconditionally at line 2532 and is reached from textViewDidChangeSelection (EditorView.swift:583-585) AND from the end of storageDidEdit (EditorViewModel.swift:1079). Only the tail-region and sealed guards can return earlier, and neither covers ordinary in-block typing. The constant is the repo's own: CrossBlockEditPlanner.swift:141-153 documents the IDENTICAL loop shape measuring 23.8 s at 20,000 entries and ~100 ms per keystroke at the author's ~1,400-paragraph bar — and this road fires on every arrow key, not only on cross-block edits. Note the codebase's other helpers (entryTouching:448, entriesIntersecting:461, the twin's fixed pass) all use a single accumulating walk, which is exactly the proven remedy. The call-site comment at EditorViewModel.swift:2529-2531 does assert the opposite cost, and the corroborating site is real: EditorSurfaceController.applyDifferential (lines 104-107) calls range(ofEntryAt: i) inside its stride loop under a comment claiming 'Cost ∝ changed blocks, never the post'. Two corrections to the finding's framing, neither refuting it: separatorPair (line 407) guards `selection.length == 1` FIRST, so it exits in O(1) for essentially every selection and is not a live hot path; and the CLASS is not unowned — KnownIssues' planVisibleTakeEdit row (owner 13u1) explicitly prescribes sweeping 'every caller of that accessor inside a loop, on both platforms, each verdicted FIXED-with-a-named-pin or provably SAFE', which this instance falls squarely inside. The marginal news is therefore the instance's identity and its hotter cadence, not the class. Severity held at MAJOR: P1 is violable here by the letter (cost ∝ block count, quadratically, on the caret/keystroke road) with a measured ~100 ms at the project's own stated document bar, but the felt cost at ordinary note sizes (a few hundred blocks) is microseconds, so it is not BLOCKER-class.

---

### P17. applyDifferential walks the block index from zero for every slot — O(N²) in blocks on BOTH platforms' live editors, unguarded

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:107`

**MINOR** · CONFIRMED · perf-p1 · lens: architecture conformance · confidence 0.90

**Mechanism**

BlockRangeIndex.range(ofEntryAt:) walks `entries` from index 0 on every call (BlockRangeIndex.swift:74-81; `entries` is a stored array at :36, no memoization), so the call is O(i). Both live editors call it unconditionally once per slot inside a loop over every slot, with no guard and no accumulation: EditorSurfaceController.swift:103-111 and MobileEditorViewModel.swift:658-666. Concrete path: open a post with N blocks; any store projection whose block/variant sequence is unchanged routes to `.differential` via EditorProjectionPolicy, and the loop then performs Σi ≈ N²/2 entry-walk steps on the main actor before comparing a single character. N=500 blocks ⇒ ~125,000 iterations per projection apply; N=5,000 (AppSpec §4's contemplated 100k-word single post) ⇒ ~12.5M iterations, tens of ms of main-actor stall, at autosave-settle cadence. Cost is proportional to document size, which is P1's one prohibition. A third, lower-severity site is ReadPostViewModel.swift:218 — same loop shape but a text-inequality `continue` above it reduces it to O(N × changedSlots), quadratic only when a sync pull lands many slot texts of one post at once.

**Evidence**

> BlockRangeIndex.swift:74-81 — `func range(ofEntryAt i: Int) -> NSRange { var location = 0; for (j, entry) in entries.enumerated() { if j == i { return NSRange(location: location, length: entry.length) }; location += entry.length + 1 } ... }`. EditorSurfaceController.swift:105-107 — `for i in stride(from: new.count - 1, through: 0, by: -1) { let newText = new[i].text ?? ""; let range = model.index.range(ofEntryAt: i)`. MobileEditorViewModel.swift:660-662 — `for i in stride(from: new.count - 1, through: 0, by: -1) { let newText = new[i].text ?? ""; let range = index.range(ofEntryAt: i)`.

**Why it matters**

P1 is a hard constraint, not a nice-to-have: 'No operation's cost may scale with total document size — only with viewport + edit.' KnownIssues carries this exact accessor-in-a-loop CLASS but names only one surviving instance (planVisibleTakeEdit); its remedy text explicitly demands the class be 'swept to completion — every caller of that accessor inside a loop, on both platforms, each verdicted FIXED-with-a-pin or provably SAFE.' That sweep was never run, and these two sites are the highest-traffic survivors, named nowhere. The accumulation remedy is already proven twice in-repo: IdentityProjectionAudit.swift:69 ('range(ofEntryAt: i) is O(i), so a running-location walk...') and CrossBlockEditPlanner.swift:141-153, the fix KnownIssues cites at 23.8 s → 0.003 s at 20,000 entries.

**Verifier**

Code claims verified verbatim. BlockRangeIndex.range(ofEntryAt:) (App/Variorum/Shared/EditorBrain/BlockRangeIndex.swift:74-81) walks `entries` from 0 with no memoization; EditorSurfaceController.swift:104-111 and MobileEditorViewModel.swift:658-666 (actual path App/Variorum/VariorumMobile/Features/Write/) both call it once per slot in a loop with no continue-guard, so the walk is Σi ≈ N²/2. ReadPostViewModel.swift:218 does carry the text-inequality `continue` above it, exactly as the finding says. The in-repo remedy precedent is real (IdentityProjectionAudit.swift:69 does the running-location walk and names the same O(entries²) reason; CrossBlockEditPlanner.swift:141-153 the same). BUT TWO OF THE FINDING'S CLAIMS ARE REFUTED. (1) The road: 'any store projection whose block/variant sequence is unchanged routes to .differential' is wrong. EditorProjectionPolicy.decide (EditorProjectionEngine.swift:146-157) pins the precedence not-loaded ▸ busy ▸ forced ▸ ECHO ▸ DELIVERY-REFETCH ▸ same-sequence ▸ full — so every ValueObservation delivery goes .refetchFresh, and every autosave echo goes .adoptEcho (the ledger's zero-surface-read match). .differential fires only on a fresh non-delivery read whose text genuinely differs: a take switch (sameSequence compares blockIDs only), restoreCommit, a sync landing. That is not 'autosave-settle cadence'. (2) 'named nowhere': KnownIssuesAndTechDebt.md's planVisibleTakeEdit row owns this exact accessor-in-a-loop CLASS at 13u1 and its remedy text mandates sweeping 'every caller of that accessor inside a loop, on both platforms' — these sites fall inside that named owner's mandate, so already_known is understated. Severity down to MINOR: no user-visible wrong behaviour, and the quadratic term only bites at thousands of blocks in ONE note, on a non-keystroke road. Worth noting as a bonus the reviewer missed: the same loop calls model.viewText(range) for every slot, so the function is O(document chars) regardless of the accessor — its own doc comment 'Cost ∝ changed blocks, never the post' is inaccurate on both counts.

---

### P18. Queries.trayTakes full-scans the `variant` table inside the tray panel's held observation, contradicting its own P1 doc claim

`Sources/VariorumCore/Queries/PoolAndTray.swift:359`

**MAJOR** · CONFIRMED · perf-p1 · lens: read layer & P1 · confidence 0.92

**Mechanism**

trayTakes starts FROM variant and only reaches the note through a post-join filter, `COALESCE(cb.container_id, b.last_container_id) = :post`, which is not seekable. idx_variant_block is (block_id, status) and cannot serve a query with no block_id; there is no index on variant.deleted_at anywhere in Migrations.swift. Verified plan against the rebuilt real schema: `SCAN v` — a full B-tree scan of the largest table in the store — then per-row seeks into block/container_block, then USE TEMP B-TREE FOR ORDER BY. Measured: 2.31 ms at 12,030 variants, 25.57 ms at 120,830 — exactly linear, and this is the cheapest possible case because the probe has ZERO deleted variants, so every row is rejected on `deleted_at IS NOT NULL` before any join fires. The call site is not a one-shot: TrayPanel.swift:357-377 puts it inside a single `session.database.observe { ... }` held for as long as the note is open, whose region includes `variant`, so every autosave re-runs the scan. Its four siblings in that same snapshot (trayBlocks, archivedBlocks, preservedOriginals, originFamilyClocks) are correctly note-scoped via `b.last_container_id = :post` on idx_block_last_container; trayTakes is the lone one that is not. Post-13p, each pass also decrypts every page of the variant table under SQLCipher.

**Evidence**

> PoolAndTray.swift:353-355 doc: "Cost ∝ this note's own fan history (`idx_variant_block` and the ownership index), never the corpus — and it is a DELIBERATELY-opened panel's read". The SQL: `FROM variant v` ... `WHERE v.deleted_at IS NOT NULL AND v.deleted_at >= :cutoff ... AND COALESCE(cb.container_id, b.last_container_id) = :post`. Measured plan first line: `SCAN v`. TrayPanel.swift:375 `takes: try Queries.trayTakes(` inside `session.database.observe({ [postID] db in Snapshot(` at :357.

**Why it matters**

AppDatabase.observe's own contract (AppDatabase.swift:210-215) states the rule this breaks: "A held observation's fetch must itself be viewport-shaped ... Observing an unbounded projection is a P1 violation waiting for a keystroke." The LIMIT bounds the rows returned, not the scan that produces them. The existing KnownIssues row for this pane asserts "cost ∝ the pane's listing, P1's letter intact; the FREQUENCY changed, not the scaling" — that premise is false here, so the row currently under-describes the defect it owns.

**Verifier**

Traced and measured. The SQL at PoolAndTray.swift:363-380 is quoted accurately, and the plan against the rebuilt real schema is `SCAN v` (then correlated purge_intent seek, then seeks into block / container_block / variant, then USE TEMP B-TREE FOR ORDER BY). I confirmed the index premise exhaustively: `grep -n INDEX Migrations.swift` shows every index in the store, and there is none on variant.deleted_at — idx_variant_block is (block_id, status) and cannot serve a query with no block_id, and COALESCE(cb.container_id, b.last_container_id) = :post is not sargable, so nothing can seek. Timings: 0.58 ms at 24,000 variants -> 9.35 ms at 240,000 — exactly linear. The sibling contrast is accurate: trayBlocks/archivedBlocks/preservedOriginals/trayCounts all drive from `FROM block b ... WHERE b.last_container_id = :post` (PoolAndTray.swift:95/99, 180/183, 258-278) on idx_block_last_container; trayTakes alone starts FROM variant. The hold is real — TrayPanel.swift:375 sits inside the single session.database.observe at :357, started by `.task { await model.start() }` at :800, and the panel lives in the inspector, which can stay open while she types (the existing KnownIssues row says so in as many words). The doc at PoolAndTray.swift:353-355 ("Cost ∝ this note's own fan history ... never the corpus") is therefore false, and the KnownIssues row that owns this pane explicitly asserts the opposite of the defect ("P1's letter intact; the FREQUENCY changed, not the scaling"), so this is NOT a documented, accepted tradeoff — it is a documented denial of it.

---

### P19. Queries.versionOfNote is an N+1 in the Trash listing, and each call scans every post in the corpus (96 ms at 20k notes)

`Sources/VariorumCore/Queries/Trash.swift:180`

**MAJOR** · CONFIRMED · perf-p1 · lens: read layer & P1 · confidence 0.90

**Mechanism**

trash()'s .note arm calls versionOfNote once per born-archived row inside a Swift .map (Trash.swift:180-182). That statement (NoteVersions.swift:292-311) has no seekable driver for the note side, so SQLite's plan — verified with EXPLAIN QUERY PLAN against the real schema rebuilt from Migrations.swift, stats-free exactly as ships (the repo never runs ANALYZE) — is: SEARCH mine USING INDEX idx_cblock_order (container_id=?) / SEARCH n USING INDEX idx_container_kind (kind=?) / SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX / SEARCH theirs USING INDEX idx_cblock_order. `n` is driven before `theirs`, so the loop is (the version's placements x every post in the corpus). Measured on a seeded probe: 7.02 ms at 2,005 containers, 96.36 ms at 20,006 containers — one call. trash() is HELD live: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit: Self.window + 1 where window = 500 (RecoveryView.swift:199), and the observation's region includes `variant` (the .take arm and strandedOriginals' preview join), so it re-fires at autosave rate. Concrete failure: with 20 deleted saved versions in the Trash and a 20k-note corpus, each observation fire costs ~1.9 s of container walking, and every keystroke's autosave triggers one.

**Evidence**

> Trash.swift:180 `let peer = (row["born_archived"] as Int?) == 1` / :181 `? try versionOfNote(db, versionID: row["id"])` — inside `.map { row -> TrashItem in }`. NoteVersions.swift:305 `JOIN container n ON n.id = theirs.container_id AND n.kind = 'post' AND n.id <> :version`. Measured plan line: `SEARCH n USING INDEX idx_container_kind (kind=?)`. Timings 7.02 ms (2,005 containers) -> 96.36 ms (20,006).

**Why it matters**

P1 is binding: no operation's cost may scale with corpus size. This one does, quadratically-ish, on a live observation that GRDB re-fires whenever `variant` is written — i.e. on every autosave. It is also the surface a user opens precisely when something has gone wrong and they need it to be responsive.

**Verifier**

Traced end to end. Trash.swift:180-182 does call `versionOfNote` inside the `.note` arm's `.map`, once per row whose selected `born_archived` is 1. I rebuilt the shipping schema from Migrations.swift (verified: no ANALYZE anywhere in Sources/App, so the planner runs stats-free exactly as it ships) and ran EXPLAIN QUERY PLAN on the verbatim statement from NoteVersions.swift:292-311. The plan is exactly as claimed: `SEARCH mine USING INDEX idx_cblock_order (container_id=?)` / `SEARCH n USING INDEX idx_container_kind (kind=?)` / `SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX` / `SEARCH theirs USING INDEX idx_cblock_order` — `n` is driven before `theirs`, so the inner loop really is (the version's placements x every post in the corpus). My own timings on a seeded probe: 3.06 ms at 2,001 containers -> 34.48 ms at 20,001, i.e. linear in corpus (about 1/3 the reviewer's absolute numbers, presumably a different blocks-per-note density, but the same shape and order of magnitude). The hold is real: Trash.swift:569 observeTrash -> RecoveryView.swift:275/295 with limit 501, and AppDatabase.observe's own doc (AppDatabase.swift:200-217) confirms table-grained region tracking that re-fires "in the worst case at autosave rate". One correction to the finding's supporting detail, which does not change the verdict: the `.take` arm never runs here — TrashScope.listedKinds (RecoveryActs.swift:466-468) is {.note,.book,.block,.preservedOriginal} — but the `.block` arm's `LEFT JOIN variant dv` puts `variant` in the region anyway, so the autosave-rate claim survives. Not documented as accepted: trash()'s own header concedes only the strandedOriginals walk and asserts it is "not a held per-keystroke one" (it is a held observation), and versionOfNote's doc makes no cost claim at all. Realistic trigger is ordinary, not exotic: versions ride a note's deletion on its exact stamp, so deleting one note with 15 saved moments puts 15 born-archived rows in the window at once.

---

### P20. The version-history classifier has no index, so deleteContainer walks every post in the corpus inside its write transaction — even for a note with zero versions

`Sources/VariorumCore/Queries/NoteVersions.swift:230`

**MINOR** · CONFIRMED · perf-p1 · lens: read layer & P1 · confidence 0.90

**Mechanism**

versionHistoryPredicate (NoteVersions.swift:146-185) has only two non-subquery terms — `archived_at IS NOT NULL` and `archived_at = created_at` — and neither column is indexed in Migrations.swift. Verified plan for noteVersionIDs against the rebuilt real schema: `SEARCH v USING INDEX idx_container_kind (kind=?)`, i.e. a walk over every post in the corpus, with the correlated EXISTS evaluated for each born-archived row. Operations+Container.swift:387 calls it on the WRITE path, inside `try database.write { db in ... for versionID in try Queries.noteVersionIDs(db, of: id) }`. The EXISTS is correlated on v.id, so it cannot short-circuit: a note with no saved versions pays the full walk. Measured for a PLAIN note with zero versions: 0.15 ms at 2,005 containers -> 4.29 ms at 20,006 (and ~300-350 ms on a cold page cache). restoreContainer:428 pays the same shape through versionHistoryDeletedWith (`WHERE v.deleted_at = :stamp`, also unindexed; 0.11 -> 1.09 ms). Multi-select delete loops the whole operation (NoteDeletion.swift:139-147 `for id in postIDs { try ops.deleteContainer(id) }`), so selecting 50 notes costs 50 corpus walks in 50 serialized write transactions (~215 ms warm at 20k, far worse cold) during which every autosave blocks on the writer. Same root on the read side: noteVersions (held via observeNoteVersions, NoteVersions.swift:330 — 0.32-5.4 ms at 2k -> 11-15 ms at 20k warm, 353 ms cold) and archivedPosts' `NOT (versionHistoryPredicate(.anyLiveNote))` fence (held via observeArchivedPosts — 0.18 -> 5.22 ms).

**Evidence**

> Operations+Container.swift:383-387: `public func deleteContainer(_ id: String) throws { try database.write { db in var container = try liveContainer(db, id); let now = date.now; for versionID in try Queries.noteVersionIDs(db, of: id) {`. NoteVersions.swift:190-192 doc: "Cost is the note's own version count (each row reads its block count and one preview), never the corpus". Measured plan: `SEARCH v USING INDEX idx_container_kind (kind=?)`. Plain-note timing 0.15 ms (2,005) -> 4.29 ms (20,006).

**Why it matters**

P1 forbids exactly this: cost proportional to corpus, not to the edit. Here it sits inside the exclusive write transaction, so it does not merely cost time — it holds the single writer while every pending autosave queues behind it, and it grows with the corpus forever. The read roads carry doc comments asserting the opposite of what the planner does, so a future reader has no warning.

**Verifier**

Mechanism confirmed, magnitude corrected down. versionHistoryPredicate (NoteVersions.swift:174-186) really does have only `archived_at IS NOT NULL` and `archived_at = created_at` as non-subquery terms, neither indexed; the plan for noteVersionIDs against the rebuilt schema is `SEARCH v USING INDEX idx_container_kind (kind=?)` with the EXISTS as a correlated subquery, i.e. a walk over every post. The call site is exactly as quoted: Operations+Container.swift:383-387 runs it inside `try database.write`, and restoreContainer:428-431 runs versionHistoryDeletedWith the same way; NoteDeletion loops deleteContainer per selected note. So the shape is real and P1's letter is broken, and both doc comments (NoteVersions.swift:190-192 "never the corpus"; observeNoteVersions "P1: never the corpus") are false as written. What I could not reproduce is the consequence: my seeded probe measures 0.11 ms at 2,001 containers and 1.18 ms at 20,001 for a plain note — the `archived_at = created_at` test rejects almost every row before the EXISTS fires, so the walk is a cheap index scan plus a deferred row read, not the 4.29 ms claimed, and a 50-note multi-select costs ~60 ms warm rather than ~215 ms. The cold-cache figures (~300-350 ms) are unverified and I would not rely on them. Real, traced, and worth fixing (an index on the classifier, or narrowing the driver), but the actual cost at any corpus she will have this year is single-digit milliseconds inside a short write transaction — narrow, not a defect a user hits.

---

### P21. Queries.activeFans issues one SQLite query per block in a Swift loop, on the held takes projection

`Sources/VariorumCore/Queries/TakesQueries.swift:123`

**MINOR** · CONFIRMED · perf-p1 · lens: read layer & P1 · confidence 0.85

**Mechanism**

activeFans loops the block ids and runs a separate Variant fetch per block. takesProjection (TakesQueries.swift:87) passes every non-gap slot of the post, and takesProjection is the body of observeTakes (TakesQueries.swift:337), a held observation whose region includes `variant` — so it re-fires at autosave rate, issuing one statement per block each time. Measured on an 800-block note against the rebuilt real schema: 7.81 ms for the shipped N-query shape vs 1.96 ms for the equivalent single `block_id IN (...)` statement — ~4x. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. Both shapes are proportional to the note rather than the corpus, so this is a constant factor, not an asymptotic P1 break.

**Evidence**

> TakesQueries.swift:121-129: `var fans: [String: [Variant]] = [:]` / `for blockID in blockIDs {` / `fans[blockID] = try Variant.filter(Column("block_id") == blockID && ...).order(...).fetchAll(db)`. TakesQueries.swift:333 doc on observeTakes: "One post's combined projection — bounded by construction (cost ∝ this post)." Measured: 7.81 ms (N queries) vs 1.96 ms (one IN-list query) at 800 blocks.

**Why it matters**

It is a textbook N+1 against SQLite sitting on a keystroke-rate observation, on both platforms, in a function whose own comment presents it as the single canonical home for this fetch — so the shape will be copied rather than questioned as new take surfaces are built.

**Verifier**

Accurate as written, including the self-correction that it is a constant factor and not a P1 break. TakesQueries.swift:119-133 is a per-block `Variant.filter(...)` fetch in a Swift `for` loop; takesProjection:87 hands it every non-gap slot of the post; observeTakes:333-338 holds takesProjection, and its region includes `variant` (renderPost and activeFans both read it), so it re-fires at autosave rate. CanvasQueries.swift:62 and CompareBoardView.swift:240 call it the same way. I reproduced the measurement almost exactly on the seeded corpus: 7.23 ms for the N-query shape vs 1.98 ms for the equivalent single IN-list statement at 800 blocks (the reviewer got 7.81 / 1.96). Two things keep this narrow: cost is proportional to the note, never the corpus, so observeTakes' own doc ("bounded by construction (cost ∝ this post)") is TRUE and no documentation is falsified; and 800 blocks is a book-chapter outlier — an ordinary note of 20-50 blocks pays a few hundred microseconds of difference, off-main. Real, measured, trivially fixable, low consequence.

---

### P22. `replaceInEveryTake` is O(matches × blocks²) — `range(ofEntryAt:)` called inside a nested loop on the Replace-All-in-Every-Take road

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:2056`

**MINOR** · CONFIRMED · perf-p1 · lens: Mac editor feature · confidence 0.85 · **already in KnownIssues**

**Mechanism**

`BlockRangeIndex.range(ofEntryAt: i)` walks from entry 0 on every call (BlockRangeIndex.swift:74-81), so it is O(i). `replaceInEveryTake` calls it inside `for i in entries.indices` which is itself inside `for item in plan`, making the placement pass O(M·N²) for M approved matches over N blocks. A 500-match Replace All over a 5,000-block book is ~6×10⁹ iterations on the main actor. KnownIssues already owns this accessor's class at 13u1, but names only `planVisibleTakeEdit` (same file, line 1819-1820), which is O(N²) on a deliberate gesture; this third-factor instance on the ⌘F takes-scope road was never enumerated, and the row's remedy explicitly demands the class be swept to completion.

**Evidence**

> EditorSurfaceController.swift:2054-2057 — `for item in plan {` / `var placed = false` / `for i in entries.indices {` / `let entryRange = model.index.range(ofEntryAt: i)`. BlockRangeIndex.swift:74-79 — `func range(ofEntryAt i: Int) -> NSRange { var location = 0; for (j, entry) in entries.enumerated() { if j == i { return … }; location += entry.length + 1 } }`.

**Why it matters**

P1 forbids cost scaling with document size; the measured sibling fix in Mobile Round 2 went 23.8 s → 0.003 s at 20,000 entries. If the 13u1 sweep fixes only the row's named site, this one survives on a road she actually presses.

**Verifier**

Code confirmed: BlockRangeIndex.swift:74-81 walks from entry 0 on every call (O(i)), and EditorSurfaceController.swift:2053-2057 calls it as `model.index.range(ofEntryAt: i)` inside `for i in entries.indices` inside `for item in plan`. The inner loop breaks on placement, so the true cost is O(Σ_items k_item²) — worst case O(M·N²) — and it runs on the main actor. Real, and it is a genuine member of the accessor class KnownIssues already tracks. Two corrections to the finding as written: (a) the stated scale is overstated — the find bar and this index describe ONE note's rendered blocks, not a whole book, so N is blocks in a post (a 5,000-block post is a 100k+-word single note, the escape-hatch case AppSpec §4 explicitly parks); (b) it is not un-owned — the KnownIssues `planVisibleTakeEdit` row's remedy already binds the fix to be "swept to completion — every caller of that accessor inside a loop, on both platforms", which covers this site by construction, so the finding's value is enumeration of an unnamed instance rather than a new problem. MINOR is right; it is not a common-road P1 breach at realistic post sizes, and the reviewer's own already_known flag is honest.

---

## T3 — Correctness & honesty defects

The app does something other than what it says it does — a wrong value written, a refusal that lies about its cause, a receipt suppressed, a retry promised in a comment that the code makes impossible.

### P23. SegmentationRules splits on "\n" only, so a CRLF file imports as ONE block instead of one block per paragraph

`Sources/VariorumCore/Domain/SegmentationRules.swift:67`

**MAJOR** · CONFIRMED · correctness · lens: pure domain functions · confidence 0.95

**Mechanism**

`"\r\n"` is a SINGLE Swift Character and is not equal to Character("\n"), so `text.split(separator: "\n")` finds no separator in CRLF text. VERIFIED by running Swift: `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` == 1; `Character("\r\n").isNewline` == true; `.trimmingCharacters(in: .whitespaces)` leaves it unchanged. Traced path with no normalisation anywhere: ImportModel.readFiles (App/Variorum/Variorum/Features/Import/ImportModel.swift:164-170) does `Data(contentsOf: url)` -> `String(data:encoding:.utf8)` -> Operations.importPost (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `bulkSegments(text, mode:)` -> returns `[wholeFile]` -> `mintSegments` mints ONE block. INPUT: drop a Windows-authored `.md`/`.txt` on the library. OUTPUT: a note whose entire body is one block — no per-paragraph blocks, takes, lineage or reordering, and a document-sized single variant; silent, nothing refuses. Same door serves quick note (13f W5 `undoLabel:`) and mobile capture. The rest of the family disagrees with this file: BoundarySnapping.paragraphBoundaries:280, MarkdownSyntax.spans:183, MarkdownEditing.lineRanges:365 and MarkdownRendering.render:166 all key on `Character.isNewline`, which is TRUE for "\r\n", "\r", U+0085, U+2028, U+2029 — MarkdownRendering.swift:190 even says "a \r\n is one Character and stays one." Only the segmenter uses a literal "\n". No CRLF fixture exists anywhere in the suite (grep over Tests/ and both app test targets).

**Evidence**

> SegmentationRules.swift:67 — `for line in text.split(separator: "\n", omittingEmptySubsequences: false) {`  ||  ImportModel.swift:168 — `let text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)`  ||  Operations+Import.swift:46 — `let segments = SegmentationRules.bulkSegments(text, mode: mode)`  ||  MarkdownRendering.swift:190 — `// The terminator is copied VERBATIM — a "\r\n" is one`

**Why it matters**

The block is the atomic unit of the whole product (CLAUDE.md, core principles). A CRLF import silently produces a note with no blocks to fan, reorder, divide or trace lineage on, and gives P1's escape-hatch case (a 100k-word single block) for free. It also breaks the Phase 11b verification claim 'import->export round-trip sanity'. The fix belongs in the Domain law, because four other Domain/brain scanners already define a line as `Character.isNewline` and only this one does not.

**Verifier**

Traced end to end and re-measured independently. (1) The Swift fact holds: I ran `"Para one.\r\n\r\nPara two.\r\nPara three.".split(separator: "\n", omittingEmptySubsequences: false).count` and got 1, with `Character("\r\n").isNewline == true`. (2) The road is real and unguarded: `ImportModel.readFiles` (App/Variorum/Variorum/Features/Import/ImportModel.swift:157-172) does `Data(contentsOf:)` -> `String(data:encoding:.utf8)` with NO line-ending normalisation, hands the raw text to `Operations.importPost` (Sources/VariorumCore/Operations/Operations+Import.swift:46) -> `SegmentationRules.bulkSegments(text, mode:)`. (3) In `.paragraph` mode (the schema seed `('default_segmentation','paragraph')`, resolved by `globalSegmentation` at Operations+Import.swift:88-92) the single un-split 'line' is not blank, so `trimmedPiece` returns the whole file and ONE segment comes back; `mintSegments` (Operations+Import.swift:98-111) mints exactly one block per segment, so the whole document becomes one block/one variant. Nothing refuses, nothing warns. (4) I searched for any normalisation or prior decision: `grep -rn 'CRLF|line ending' notes/` returns exactly ONE hit, notes/plans/phase-13d-refusal-ergonomics-floor.md:3016, and it is about a DIFFERENT function — `seamTrimmedHalves`' `count(where: \.isNewline)` — where it correctly reasons that grapheme clustering makes `\r\n` safe. So the class was reasoned about and this call site was missed; it is NOT an owned tradeoff. (5) The finding's family claim checks out: BoundarySnapping's paragraph/word scanners, MarkdownSyntax, MarkdownEditing and MarkdownRendering all key on `Character.isNewline` (true for `\r\n`); only the segmenter uses a literal `"\n"` Character comparison, which grapheme clustering makes false for CRLF. Severity kept at MAJOR: silent, deterministic, on a shipped user-facing door, and it defeats the block-as-atomic-unit for the entire imported note (no fan/reorder/divide/lineage granularity, one document-sized variant). Held BELOW blocker deliberately — no text is lost or corrupted, the paragraphs still render as content under I4, and recovery is re-import after conversion. Sentence mode degrades less (its scanner keys on `isWhitespace`, which is true for `\r\n`), so paragraph mode — the default — is the exposed one.

---

### P24. The Mac computes churn from the WIDENED NSTextStorage report, so a typo fix inside existing prose stamps last_major_revision_at

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1148`

**MAJOR** · CONFIRMED · correctness · lens: shared editor brain · confidence 0.90

**Mechanism**

storageDidEdit receives the SAME didProcessEditing report the repo's own pin measures as widened: EditorView.swift:588-598 forwards the .editedCharacters callback, and IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph pins that typing one character at offset 2 of "Alpha\n…" reports {2,5} with delta +1. recordAutosave then computes oldLength = editedRange.length - delta = 4 and charDelta = oldLength + editedRange.length = 9 for a 1-character edit — a 9x overcount; in general ~2 x (characters from the caret to the paragraph end). AutosaveCoordinator.record sums those (Shared/AutosaveCoordinator.swift:113) and passes the sum to ops.autosave (line 157), which reaches Operations.registerTextChange -> Churn.accumulate (Operations+Variant.swift:446-457) and stamps last_major_revision_at + rebaselines baseline_length on crossing. Concrete: a 5-block x 400-char note (baseline_length 2000, threshold 0.8 => 1600). Fixing a typo at offset 10 of block 1 reports ~{10,392} per keystroke => charDelta ~783. THREE keystrokes = 2349 >= 1600 => last_major_revision_at stamps and the post rebaselines. True churn for those three keystrokes is 3 (ratio 0.0015). The shared brain already carries the fix and the Mac never adopted it: ArmedEdit.exactCost (Shared/EditorBrain/EditorEditRouting.swift:62) is read only by MobileEditorViewModel (lines 1438, 1458, 1547 — `charDelta: exactCost ?? (oldLength + editedRange.length)`); `grep -rn exactCost App` shows zero Mac consumers.

**Evidence**

> EditorViewModel.swift:1145-1148 — `let oldLength = editedRange.length - delta` / `autosave.record(variantID: variantID, text: text, charDelta: oldLength + editedRange.length)`. The pinned measurement, IdentityProjectionAuditTests.swift:279-280 — `// A 1-character insertion reports 5 — the paragraph's tail and its terminator.` / `#expect(spy.reports == [NSRange(location: 2, length: 5)])`. The unread fix, EditorEditRouting.swift:57-62 — `/// The policed edit's EXACT churn cost … Platforms that derive cost from the report simply never read it (the Mac).` / `var exactCost: Int { range.length + replacementLength }`. The consumer, MobileEditorViewModel.swift:1547 — `charDelta: exactCost ?? (oldLength + editedRange.length))`.

**Why it matters**

It silently defeats a named product pillar. CoreDescription pillar 7: "Fixing one typo must never reshuffle the library"; AppSpec §10 defines the math this feeds. reading.sort_field accepts 'last_major_revision' and the library sort reads the same stamp, so the user-visible consequence is exactly the reshuffle the feature exists to prevent. churn_accumulator, baseline_length and last_major_revision_at are synced columns, so the wrong values propagate to the phone. It is also a Mac/mobile drift on ONE shared brain (MobileSoul §3's class). Nothing pins it: the only churn tests are AutosaveCoordinatorTests (synthetic charDelta, never the editor's) and FindAndReplaceTests:241 (`#expect(churnAfter > churnBefore)` — cannot distinguish 1 from 783).

**Verifier**

Traced end to end in the real source. EditorView.swift:588-598 forwards the .editedCharacters didProcessEditing report to EditorViewModel.storageDidEdit; on a .block(i) verdict (line 1034) it hands the SAME editedRange/delta to recordAutosave, which computes `oldLength = editedRange.length - delta` and `charDelta: oldLength + editedRange.length` (EditorViewModel.swift:1145-1148) — i.e. 2*reportedLength - delta. The widening is pinned in-repo ON THE PRODUCTION CONFIGURATION: IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph installs a spy on the same didProcessEditing callback inside `withEditor`, which builds the real EditorTextView.makeEditor() + real EditorSurfaceDelegate (EditorTestSupport.swift:183-186), and asserts a 1-char insert at offset 2 reports {2,5} — so charDelta = 9 for a true cost of 1, and the overcount scales with the distance from the caret to the paragraph terminator. The cost then flows AutosaveCoordinator.record (sums, Shared/AutosaveCoordinator.swift:106-113) -> flushNow -> ops.autosave -> Operations.registerTextChange -> Churn.accumulate -> stamps lastMajorRevisionAt and rebaselines baselineLength (Operations+Variant.swift:436-461); nothing on that road normalizes the cost. The shared fix exists and the Mac genuinely never reads it: `grep -rn exactCost App Sources` returns only EditorEditRouting.swift:62 (the definition) and four MobileEditorViewModel lines. Every other Mac charDelta call site computes an exact cost (BlockTOCView:172, TakesViewModel:576, CanvasViewModel:682, EditorFind, EditorSurfaceController:1872/1961/1975), so the keystroke road is the sole report-derived one. Not a documented acceptance: exactCost's own comment frames the widening as what "iOS applies", which pre-dates 13l's macOS-26 measurement (TEXTKIT2_NOTES records that measurement as FALSIFYING the earlier 'AppKit does not widen'), and KnownIssues carries no churn row. The stamp is user-visible through BookOrderAndConversion.swift:51 ('Major revision ↓'), TimelineView.swift:26, and ReadingAssembly.swift:380, which is exactly the sort CoreDescription pillar 7 / AppSpec §10 exist to keep meaningful. Severity held at MAJOR: wrong behaviour a user reaches on a real sort, defeating a named product pillar, but no data loss or corruption (churn is a counter, and SyncSpec's merge matrix already treats it as approximate under sync).

---

### P25. Mac churn cost is derived from AppKit's WIDENED edited-range report, so one keystroke inside a block over-reports churn by ~2× the paragraph tail

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1145`

**MAJOR** · CONFIRMED · correctness · lens: Mac editor feature · confidence 0.90

**Mechanism**

`recordAutosave` computes `charDelta = (editedRange.length - delta) + editedRange.length` from the RAW NSTextStorage report. This repo's own pinned measurement (`IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph`) proves macOS 26 attribute fixing widens an insertion's report to the paragraph end INCLUDING the terminator: typing "X" at offset 2 of block "Alpha" reports {2, 5} with delta 1. So charDelta = (5-1) + 5 = 9 for an edit whose true cost is 0 deleted + 1 inserted = 1. Generalised: a 1-char insertion at intra-block offset p in a paragraph of length M reports ≈ 2·(M − p + 1) − 1, so one character near the start of a 500-char paragraph reports ~1000 instead of 1. AutosaveCoordinator.record sums these across the debounce window; Operations.autosave → registerTextChange → Churn.accumulate then stamps container.last_major_revision_at and rebaselines once churn/max(baseline,1) ≥ 0.8 (Operations+Variant.swift:23-25, 446-459). Result: a few typo fixes inside long paragraphs stamp the note as majorly revised, collapsing reading.sort_field='last_major_revision' into 'last_touched'. The exact value already exists — ArmedEdit.exactCost (range.length + replacementLength) — and `storageDidEdit` computes the bound ArmedEdit at line 1000 but never passes it down; grep -rn exactCost App/ returns zero Mac hits while MobileEditorViewModel.swift:1547 consumes it (`charDelta: exactCost ?? (oldLength + editedRange.length)`). 13l applied the clamp rule to the attribute stamp two lines above (`stampProjection(... within: entryRange)`) and not to the arithmetic. No test drives the real typed path and asserts the recorded cost.

**Evidence**

> EditorViewModel.swift:1145-1148 — `let oldLength = editedRange.length - delta` / `autosave.record(variantID: variantID, text: text, charDelta: oldLength + editedRange.length)`. IdentityProjectionAuditTests.swift:277-279 — `// A 1-character insertion reports 5 — the paragraph's tail and its terminator.` / `#expect(spy.reports == [NSRange(location: 2, length: 5)])`. EditorEditRouting.swift:58-62 — `/// The policed edit's EXACT churn cost … Platforms that derive cost from the report simply never read it (the Mac).` / `var exactCost: Int { range.length + replacementLength }`. MobileEditorViewModel.swift:1547 — `charDelta: exactCost ?? (oldLength + editedRange.length))`.

**Why it matters**

It silently corrupts a canonical persisted value (container.churn_accumulator / last_major_revision_at) and breaks a stated product pillar verbatim: CoreDescription §7, "Fixing one typo must never reshuffle the library." It is also a live Mac/mobile divergence in a shared brain — the corrected arithmetic was hoisted for both platforms and only the phone adopted it, which is exactly the MobileSoul §3 drift class.

**Verifier**

Traced end to end. EditorViewModel.swift:1144-1148 (`recordAutosave`) computes `charDelta: oldLength + editedRange.length` from the RAW report, where `oldLength = editedRange.length - delta`. The report reaching it is the NSTextStorageDelegate `didProcessEditing` range (EditorView.swift:588-599 → `model.storageDidEdit`), which is exactly what IdentityProjectionAuditTests.swift:258-281 measures with a temporarily-swapped spy on the SAME single storage delegate, driven through the real AppKit road (`EditorTestSupport.swift:98` — `textView.insertText`): a 1-char insert at offset 2 of "Alpha" reports {2,5}, delta 1 ⇒ charDelta 9 for a true cost of 1. TEXTKIT2_NOTES.md records this as the pinned macOS 26 finding that FALSIFIES the earlier "AppKit does not widen" belief, and 13l's stated rule ("clamp attribute stamps to the VERDICT's range, never the report's") was applied only to `stampProjection` two lines above, not to the arithmetic. The over-reported value is real currency: AutosaveCoordinator.swift:113 sums it across the debounce window, Operations+Variant.swift:16-27 passes it to `registerTextChange` (:438-461), which folds it into `Churn.accumulate` and, on crossing the 0.8 threshold, stamps `container.last_major_revision_at` and rebaselines. Generalised: a 1-char insert at offset p in a paragraph of pre-edit length M records 2(M−p)+3, so a typo fix near the start of a long single-paragraph note can cross the threshold on a SINGLE keystroke — directly defeating CoreDescription §7 ("Fixing one typo must never reshuffle the library"). The corrected value already exists and is hoisted: `ArmedEdit.exactCost` (Shared/EditorBrain/EditorEditRouting.swift:58-62), whose own doc says "Platforms that derive cost from the report simply never read it (the Mac)" — but that comment predates the macOS-26 widening measurement, so it documents the Mac's non-use, not an accepted over-report. grep confirms the only consumers are MobileEditorViewModel.swift:1438/1458/1547; zero Mac hits. Other Mac autosave call sites (TakesViewModel:576, CanvasViewModel:682, BlockTOCView:172) pass their own computed cost — the Write editor is the outlier. No test in VariorumTests asserts a charDelta recorded from the real typed path. Severity MAJOR stands: common road (any mid-block edit), silent corruption of a canonical persisted sort value, no crash or text loss.

---

### P26. MobileLivenessAuthority.takeLiveness grants the pen from a stale continuation — two editors end up isLive at once

`App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift:107`

**MAJOR** · CONFIRMED · concurrency · lens: concurrency & threading · confidence 0.75

**Mechanism**

`takeLiveness` writes `live = editor` (:112) BEFORE two suspension points (`await editor.autosave.flushNow()` :113, `await editor.refreshTakesFromStore()` :115) and hands the pen over AFTER them (`editor.noteLivenessGranted()` :117), with no check that `live` is still this editor. The caller fires an unstructured, unlatched Task per tab tap (MobileShellView.swift:303 `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }`), so two taps interleave. Trace: (1) tap tab B — Task1 stands down editorA, sets `live = editorB`, suspends inside editorB's flush (a real GRDB write through OperationsRunner); (2) tap tab A before that write returns — Task2's loop calls `editorB.standDown()` (isLive=false, endEditing(true), isEditable=false), sets `live = editorA`, flushes, refreshes, grants A; (3) Task1 resumes and calls `editorB.noteLivenessGranted()`, which sets `isLive = true` and `textView?.isEditable = true` (MobileEditorViewModel.swift:296-301). End state: `live === editorA` while editorB is also isLive and editable.

**Evidence**

> MobileLivenessAuthority.swift:112-117 — `live = editor` / `await editor.autosave.flushNow()` / `if refresh { await editor.refreshTakesFromStore() }` / `editor.noteLivenessGranted()`. MobileEditorViewModel.swift:296-301 — `func noteLivenessGranted() { isLive = true; if !takesBrowser.isOpen { textView?.isEditable = true } }`. MobileEditorViewModel.swift:1199-1205 — `// The liveness belt (S3 ladder BLOCKER): a stood-down surface is read-tier ... if !isLive { refuse("This note is live in your other tab."); return false }`. MobileShellView.swift:303 — the unlatched `Task { ... await editors.tabDidBecomeVisible(target) }`.

**Why it matters**

The type's own header states the law — "at most one is the law, not exactly one" (:91) — and `isLive` is the authorization gate that a ladder BLOCKER installed at MobileEditorViewModel.swift:1202. After this race that belt is defeated on a surface deliberately stood down, and two tab stacks holding the SAME post is an explicitly supported state (`registeredPostIDs` dedupes for exactly that reason, :61-68) — the stale-photograph class the authority exists to prevent. Mitigating fact, stated honestly: the wrongly-granted editor is always the earlier switch's target, i.e. the now-hidden tab, so no keystroke has been traced into it before the next `tabDidBecomeVisible` heals it — the invariant is broken; loss is not demonstrated. MobileLivenessTests drives every transition strictly sequentially, so nothing pins it. The Mac's equivalent (PaneTextAuthority — a pure value type with one `livePane` optional) is structurally immune, so this is a mobile-only regression of a Mac-side design property.

**Verifier**

Verified line by line. MobileLivenessAuthority.swift:107-118: `takeLiveness` stands down siblings synchronously, sets `live = editor`, then awaits `editor.autosave.flushNow()` (AutosaveCoordinator.swift:142 — a real suspension, `try await runner.run { ops.autosave(...) }` per pending variant) and `editor.refreshTakesFromStore()`, and finally calls `editor.noteLivenessGranted()` with NO re-check that `live === editor`. `@MainActor` does not serialize across suspensions, so this is a textbook check-then-act-across-await. Confirmed the entrant: MobileShellView.swift:296-306 fires an unstructured, unlatched `Task { await quickNote.fileOnLeaving(); await editors.tabDidBecomeVisible(target) }` per tab tap with only `guard tab != target`, so a second tap enters concurrently; MobileWriteView.swift:168 `await router.editors.register(model, tab: tab)` is a second unlatched entrant. noteLivenessGranted (MobileEditorViewModel.swift:296-301, file is at Features/Write/, not Features/Editor/ as cited) and the gate belt (:1200-1205) are exactly as quoted. TWO partial refutations, both stated honestly by the finding's own end state: the hidden stack is `.allowsHitTesting(tab == .shelf/.library)` (MobileShellView.swift:126,138) and standDown already resigned first responder, so the wrongly-granted hidden editor has no keystroke road, and the next tabDidBecomeVisible heals it. BUT I traced a strictly worse ordering of the same defect that the finding did not: if Task1 suspends in `fileOnLeaving()` (a non-empty quick note mints — MobileQuickNote.swift:809) and Task2 runs takeLiveness(A) to completion first, Task1 then resumes into takeLiveness(B), STANDS DOWN A, and grants B — leaving the VISIBLE note uneditable and refusing with 'This note is live in your other tab.' until the user navigates away and back. That is user-visible wrong behavior from the same missing re-check, so MAJOR stands.

---

### P27. The ⌘⇧M merge threshold reads the deliberately-frozen `slots` projection, so a fanned merge silently falls through to the un-carrying instant merge — and the receipt naming the lineage road is suppressed with it

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:277`

**MINOR** · CONFIRMED · invariant-violation · lens: Mac editor feature · confidence 0.85

**Mechanism**

`applyStructural`'s `.merge` arm decides carry-all vs instant from `model.slots[i].activeVariantCount`, an array `EditorProjectionPolicy` deliberately freezes while the editor is busy. Trace: (1) she is typing ⇒ `autosave.isDirty == true`; (2) a take arrives on block B from the phone or a sync-applied conflict variant, `observeSlots` delivers, `EditorProjectionPolicy.decide(busy: autosave.isDirty || mintInFlight || structuralInFlight, …)` returns `.deferUntilClean` (EditorViewModel.swift:638-663) so `slots` is not updated and B's activeVariantCount stays 1; (3) ⌘⇧M on the A|B seam reads trailingArity == 1 and takes the `else` arm ⇒ `runInstantMerge`; (4) `runInstantMerge` never re-reads the store and computes `otherTakes = mergedAwayTakes([...])` from the SAME stale slots ⇒ 0; (5) `runStructural` flushes successfully, `ops.merge(A,B)` runs — merge accepts fanned blocks by design — and B is released to lineage with its real fan behind it; (6) `speakAboutMergedFans(0)` returns at its `guard otherTakes > 0` so nothing is said. `applyPendingIfClean` cannot rescue it: `runStructural` sets structuralInFlight = true before flushing and that method guards on `!structuralInFlight` (EditorViewModel.swift:795). The false-positive direction IS guarded (`runCarryAllMerge` re-reads via `liveActiveFans` and falls back), and the divide twin guards both directions (`runDuplicatingDivide` reads the store; a stale-unfanned divide is caught downstream because `ops.divide` throws `.fannedBlock`). `ops.merge` throws nothing on a fanned block, so this path has no backstop at all.

**Evidence**

> EditorSurfaceController.swift:277-296 — `let trailingArity = trailingIndex < model.slots.count ? model.slots[trailingIndex].activeVariantCount : 1` … `} else if leadingArity > 1 || trailingArity > 1 { await runCarryAllMerge(...) } else { await runInstantMerge(...) }`. The same file's own contract at 1749-1753 asserts the opposite: `/// The merge ceremony's threshold read, shared by the ⌘⇧M door and the seam keystroke (S4-23 ruling 4) … From the store — never model.slots, which is deliberately stale while the editor is busy.` — yet `liveActiveFans` is reached from the ⌘⇧M road only INSIDE runCarryAllMerge (line 503), i.e. only after the stale projection already said "fanned". EditorSurfaceController.swift:340 — `guard otherTakes > 0 else { return }`.

**Why it matters**

Two ruled behaviours are lost with no word spoken: her 2026-08-09 J4b carry-all-merge default does not run (the takes stay on the released source instead of riding onto the merged block), and the single line that points her at the recovery road ("N other takes stay with the released blocks … ⌥⌘Z undoes") is suppressed — which is precisely the silent-vanish experience the same file's comment claims to have closed. Recoverable via lineage/undo, so not data loss, but the code's own documented invariant ("read truth, not the projection") is false in the one direction that changes the outcome.

**Verifier**

Mechanism verified in full, severity corrected down. EditorSurfaceController.swift:276-297: `leadingArity`/`trailingArity` come from `model.slots[...].activeVariantCount`, and the `else` arm calls `runInstantMerge` with no store read. EditorProjectionEngine.swift:148-156 pins the precedence `not-loaded ▸ busy ▸ forced ▸ echo ▸ …`, so `busy` (autosave.isDirty || mintInFlight || structuralInFlight — EditorViewModel.swift:646) wins over the echo arm and `.deferUntilClean` sets `pendingProjection` WITHOUT touching `slots` (EditorViewModel.swift:661-662). `runInstantMerge` (:357-374) reads `mergedAwayTakes` from the same stale slots, so `speakAboutMergedFans` returns at its `guard otherTakes > 0` (:340) and nothing is said. `applyStructural` does not flush before the arity read (the flush happens inside `runStructural`, after the fork). The asymmetry claim is exact: `ops.divide` throws `.fannedBlock` (Operations+Structural.swift:198-202) so a stale-unfanned divide is caught downstream, while `ops.merge` (:659-674) guards only adjacency — no fan check at all. Both sibling roads read truth: `openMergeCeremony` (:1045) and `runSeamMerge` (:1705) call `liveActiveFans`, whose own doc comment (:1748-1753) states "From the store — never `model.slots`, which is deliberately stale while the editor is busy", and `planSeamMerge`'s doc (:1668-1676) says a plan-time projection read "is an enablement hint, never an authorization" and that a fan arriving mid-burst stops the merge (pinned). The ⌘⇧M door alone lacks that authorization read in the false-negative direction; the inline comment at :266-268 documents only the false-POSITIVE fallback. Severity corrected MAJOR→MINOR: reaching it needs an external take to land on one of the two blocks inside the dirty/flight window AND an immediate ⌘⇧M; the outcome is the pre-2026-08-09 shipped default (takes stay on the released sources), fully recoverable via lineage and ⌥⌘Z, with no invariant (I1–I10) violated. Worth noting it is a sibling of a class already owned by 13u1 item 8 (`BlockRangeIndex.wholeBlockDeletion`'s frozen-projection fan fence), at a road that row does not name.

---

### P28. reapplyStructural is the only revive road that does not void purge intents; a leftover Delete-Now intent later claims the block and strips its 30-day recovery window

`Sources/VariorumCore/Operations/Operations+UndoInverses.swift:404`

**MINOR** · CONFIRMED · data-loss · lens: undo/redo · confidence 0.75

**Mechanism**

revertDeleteBlock, revertDeleteVariant, restoreVariant and restoreContainerRows all call voidPurgeIntents when they flip a tombstone back, with the reason written at the site (13j ladder B, B1). reapplyStructural's untombstoningBlocks loop flips exactly the same block tombstone and does not. Trace: divide a block, type in the minted successor C (so revertStructural's `diverged` test at :300 stamps last_container_id and C lists in the note's tray) → ⌥⌘Z → press Delete Now on C in the tray, which mints a LIVE purge_intent for ('block', C) → ⇧⌥⌘Z, which un-tombstones C while the intent stands (single-device convergence is then saved only by the janitor's own .stale verdict at PurgeJanitor.swift:145-156) → but if she deletes C the ordinary way before the next sweep, the intent is still live and now names a genuinely tombstoned row: PoolAndTray.swift:107-109 fences it out of the tray (`pi.deleted_at IS NULL`), familyVerdict no longer reads .stale, and the janitor physically removes C at the horizon. C never appears in the Trash and never gets the 30-day window the ordinary delete promises.

**Evidence**

> Operations+UndoInverses.swift:59-63 — `// 13j ladder B (B1): the ⌥⌘Z road is the single-device door of // the stale-intent hole — a restored row voids any live intent // naming it, or a Delete Now confirmed BETWEEN the delete and // this undo would still purge the row she just brought back.` followed by `try voidPurgeIntents(db, table: "block", rowID: blockID)`. The mirror loop at :404-424 ends `try flipBlockCascadeTombstones(...)` with no voidPurgeIntents call. Queries/PoolAndTray.swift:107-109 — `AND NOT EXISTS (SELECT 1 FROM purge_intent pi WHERE pi.table_name = 'block' AND pi.row_id = b.id AND (pi.deleted_at IS NULL OR pi.deleted_at >= b.deleted_at))`.

**Why it matters**

The redo road is the exact mirror of the undo road the 13j ladder hardened for this reason; leaving the belt off one half means a block she deleted through the ordinary door can be hard-deleted on the horizon with no Trash listing and no Put back, which is the one outcome the Trash design exists to prevent.

**Verifier**

The asymmetry is exactly as stated. voidPurgeIntents has five callers (Operations+UndoInverses.swift:63 revertDeleteBlock, :87 revertDeleteVariant; Operations+Placement.swift:129 restoreBlock; Operations+Deletion.swift:116 restoreVariant; Operations+Container.swift:468 restoreContainerRows; plus Operations+Reading.swift:156) — every road that flips a tombstone back, each with the 13j ladder B (B1) reason written at the site. reapplyStructural's untombstoningBlocks loop (Operations+UndoInverses.swift:404-424) performs the identical block.deletedAt = nil + flipBlockCascadeTombstones transition and does not call it. The other two re-applies are safe by delegation (reapplyMintedContainer → restoreContainer, reapplyImportedBlocks → revertDeleteBlock), so this loop is the single hole. The consequence chain checks out: the fence predicates are stamp-aware and a LIVE intent (pi.deleted_at IS NULL) hides the row unconditionally (PoolAndTray.swift:107-109, Trash.swift:169 — whose own comment states the intended rule, "A VOIDED intent from before a re-delete never hides the fresh tombstone's row"), and PurgeJanitor.familyVerdict (:442-449) returns .stale only while the row is LIVE, so an ordinary re-delete before the next sweep flips the verdict to eligible and the janitor removes the bytes with no Trash listing and no Put back. Correctly rated MINOR: the janitor's .stale second net (PurgeJanitor.swift:151-156) closes it on the next sweep, so the hole is a redo→re-delete window of minutes-to-an-hour, and reaching it needs a tray/Trash Delete Now on an undone structural mint.

---

### P29. The phone's redo door documents a mechanism the code does not have — reapplyStructural DOES overwrite a buffer edited since the undo, silently

`App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift:225`

**MINOR** · CONFIRMED · drift · lens: undo/redo · confidence 0.85

**Mechanism**

reapplyStructural's restoringTexts loop overwrites working_text with postOpText and carries its own insurance commit for precisely the case the comment says cannot occur. Trace: divide(A) at a cut → ⌥⌘Z restores A's buffer to the full pre-cut text → she types a new sentence into A → ⇧⌥⌘Z → at Operations+UndoInverses.swift:431-437 `variant.workingText != preImage.postOpText` is true, `variant.workingText != preImage.text && isDirty` is true so a quiet auto-commit is inserted, then `variant.workingText = preImage.postOpText` drops her new sentence off the surface with nothing said. The doc comment asserts redo 'discards nothing she typed'; reapplyStructural's own doc two files over states the opposite ('a buffer the author edited since the UNDO is about to be overwritten by the post-op text').

**Evidence**

> MobileUndoDoor.swift:223-226 — `/// The undo door's exact mirror. No warning: redo re-applies from /// do-time pre-images and discards nothing she typed (A12 named undo /// alone, deliberately).` vs Operations+UndoInverses.swift:431-435 — `guard variant.workingText != preImage.postOpText else { continue }` / `if variant.workingText != preImage.text, try isDirty(db, variant) { _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now) }` / `variant.workingText = preImage.postOpText`.

**Why it matters**

Whether redo should warn is a product call (A12 named undo only), but a door comment that asserts a discard is impossible is the sentence a future session will trust when deciding not to add the guard — and the discard is silent on both platforms, with the only trace being an unlabelled auto-commit.

**Verifier**

The comment and the code do contradict each other. MobileUndoDoor.swift:224-226 asserts redo "discards nothing she typed"; reapplyStructural (Operations+UndoInverses.swift:426-438) skips only when workingText already equals postOpText, otherwise takes a quiet auto-commit when the buffer diverged and is dirty (:432-434) and then assigns variant.workingText = preImage.postOpText (:435) — and its own doc at :344-348 says plainly "a buffer the author edited since the UNDO is about to be overwritten by the post-op text." The divide/extract registrations (Operations+Structural.swift:246-249, :153-156) do pass restoringTexts, so the branch is live on the everyday road (undo a divide, keep typing in the rejoined block, redo). Note the substance split: the BEHAVIOUR is not a defect — A12 named undo alone and no pendingRedoWarning exists on either platform, which is deliberate — so what stands is the false door comment, and it is false even in the door family's own vocabulary (the undo road also insures first yet is still called "discarding", per StructuralUndoCopy.discardingUndoQuestion and MobileUndoDoor.discardingUndoDetail's "that writing is set aside"). Held at MINOR rather than NIT: it is not cosmetic — it asserts the opposite of a text-discarding behaviour, the class this codebase has corrected as real findings before (the LR2-1 doc correction inside restoreNoteVersion's own comment). No behaviour change is owed; the comment is.

---

### P30. The bridge's daily-book shelving failure is a one-shot ephemeral note, and its own comment promises a retry the advanced cursor makes impossible

`Sources/VariorumCore/Bridge/BridgeEngine.swift:240`

**MINOR** · CONFIRMED · error-swallowing · lens: fragments bridge · confidence 0.85

**Mechanism**

pullAndLand commits the day agreement AND advances the pull cursor at :220-229, then calls ensureDailyBookMembership at :240-247. When shelving fails (store read failure, bookFinished, bookAtCapacity, wrongKind, refused — :334-357) it returns a note appended to report.landing.notes. That note is the ONLY record, and it is doubly unreliable. (a) It never recurs: the cursor is already past that Fragments row so transport.pull(after:) never serves it again, and even if it did, recordDay wrote the day's hash in the same transaction, so land() returns .skipped at :400-402, outcome.wroteToTheDay is false (:292-299), and ensureDailyBookMembership is never called again. The only other callers of Operations.shelveInDailyJournalBook are ⌘J (BookStructureModel.swift:657) and the phone's Today door — both need the author to open that exact day; nothing sweeps. So the comment's "the next bridge round retries it" is false. (b) It is discarded outright by any failure in the same round's push half: BridgeEngine.run() runs push AFTER pullAndLand (:169-170), push throws on transport.fetchLocalUserID() (:869) or transport.push (:909) — an ordinary network hiccup — and BridgeScheduler.runOneRound only publishes status.issueNotes on the success branch (:105), keeping the previous round's values on a throw (:106-118). Concrete run: her Fragments entry for 2026-09-01 lands into an at-capacity daily journal book; shelving returns the 'note cap' note; the push half then hits a 500 or offline. The entry is live in the Pool, permanently outside the Journal book, and nothing anywhere ever says so. Even on a clean round the note lives exactly one round in a hover tooltip (App/Variorum/Shared/BridgeStatusViews.swift:88) — the same posture the 9b round-2 MAJOR rejected for receipt notes ("the producing event is one-shot, so persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation", :1303-1311), which is why unrescuedBodyNotes (:752) and strandedDeletionDays (:845, :854-856) were made durable and recurring. BridgeDailyBookTests only asserts the note appears in the producing round's report (:193-194, :214-216, :261) — nothing pins persistence, so the gap is invisible to the suite.

**Evidence**

> BridgeEngine.swift:220-229 `try await database.write { db in ... try Self.setCursor(db, FragmentsPullCursor(serverUpdatedAt: serverStamp, id: entry.id)) }` — then :240-247 `if outcome.wroteToTheDay, let note = await ensureDailyBookMembership(day: entry.date) { report.notes.append(note) }`. BridgeEngine.swift:334-336 `return Self.unshelvedNote(day: day, because: "the store could not be read to find that day's entry — the next bridge round retries it")`. BridgeEngine.swift:292-299 `case .skipped, .deferred: return false` (wroteToTheDay). BridgeScheduler.swift:105 `status.issueNotes = report.landing.notes + report.push.notes` (success branch only); :117 `status.lastError = String(describing: error)` (catch branch keeps the old notes). Contrast BridgeEngine.swift:752 `report.notes = try await database.read { try Self.unrescuedBodyNotes($0) }`.

**Why it matters**

The 13c A1 work exists precisely because of the author's 2026-07-25 report, quoted in this file at :306-309: "fragments journal did sync and appear, but not in the journal book, just appeared in the pool". This path reproduces that exact outcome — the entry lands, never joins the Journal book, and the single notice can be discarded by an ordinary network error or scrolled away by the next round. A silent divergence in the one flow the phase was built to make honest.

**Verifier**

Traced end to end in Sources/VariorumCore/Bridge/BridgeEngine.swift and BridgeScheduler.swift. The control flow is exactly as described: the day agreement + cursor advance commit in one write (~:220-229), then ensureDailyBookMembership runs (:240-247) and can only return a String appended to LandingReport.notes. The retry promise at :334-336 ("the next bridge round retries it") is FALSE on the path it annotates: the cursor is past that Fragments row, and even a re-served row hits the echo/replay skip at :400-402 (incomingHash == context.state) whose LandOutcome.wroteToTheDay is false (:292-299), so shelving is not re-attempted. I grep-verified there is no sweep: shelveInDailyJournalBook has exactly three production callers (BookStructureModel.swift:657 ⌘J, MobileTodayDoor.swift:45, and the bridge), none of which sweeps past days. The durability contrast is real and is the project's OWN doctrine, written 40 lines above the shelving code (BridgeEngine.swift:745-752: "the producing receipt was one-shot, so the persistence does the recurring; a single ephemeral note in a replaceable tooltip was not preservation") — unrescuedBodyNotes re-reads from the store every round; the shelving note does not. Claim (b) also holds: BridgeScheduler.runOneRound assigns status.issueNotes only on the success branch (:105); a push-half throw discards the whole RoundReport including the landing's completed notes, and the catch branch's own comment ("a failed round learned nothing about them") is inaccurate for a round whose landing half succeeded. WHAT I DISCOUNTED, and why the severity drops: (1) no data is at risk — the entry is committed to the store before shelving is even attempted, and its bookless state is durably visible on the Pool surface (AppSpec: "Pool = bookless posts (R29)"); (2) the land-and-speak-on-the-round-note-surface posture is documented and ladder-adjudicated (phase-13c plan, A1 rule 1, naming LandingReport.notes → Status.issueNotes → the status row's "needs attention" as the surface); (3) bookFinished/bookAtCapacity/wrongKind are the author's own deliberate book states, which AppSpec explicitly forbids the bridge to override, and ⌘J speaks the same refusals; (4) "it never recurs" is overstated — any later WRITING landing on that day re-runs shelving and re-emits the note, so the gap is only for days Fragments stops touching. What survives is a real notification-durability gap plus a demonstrably false in-code retry promise — narrow, not user-facing loss.

---

### P31. A permanently stalled pull cursor is reported as a clean, successful sync round forever — PullReport.stalled has no production reader

`Sources/VariorumCore/Sync/SyncScheduler.swift:196`

**MINOR** · CONFIRMED · error-swallowing · lens: sync engine · confidence 0.85

**Mechanism**

SyncEngine.pull() truncates the batch at the first row whose FK closure is unsatisfiable (the straggler guard). When that is the FIRST row, stopIndex == 0, so `newCursor = since` — the cursor does not move, no row is applied — and pull() RETURNS NORMALLY with `report.stalled = true` (SyncEngine.swift:371-374). SyncScheduler.runOneRound discards the report (`_ = try await engine.pull()`) and then unconditionally executes `status.lastError = nil` / `status.lastErrorIsOffline = false` / `status.lastSuccessAt = date.now`. Concrete outcome: with one permanently unresolvable row in the changefeed (see the purge-orphan finding for one way to create one), every subsequent round integrates ZERO server rows while the status surface reports "last success: just now" indefinitely. Pushes are unaffected, so local writes keep flowing to the mirror and the two stores diverge one-way, silently, under a green light. `grep -rn 'stalled' Sources/ App/` finds no production consumer — only Tests/VariorumCoreTests/SyncPullTests.swift:162,326. PushReport.deferred (rows left enqueued because their referents never arrived) is discarded the same way. The pattern exists and was deliberately applied in the sibling subsystem: BridgeScheduler.swift:104 does `status.stalled = report.landing.stalled`.

**Evidence**

> SyncScheduler.swift:195-200 — `// Pinned: pull → push (A3).` / `_ = try await engine.pull()` / `_ = try await engine.push()` / `status.lastError = nil` / `status.lastErrorIsOffline = false` / `status.lastSuccessAt = date.now`.  SyncEngine.swift:371-374 — `let newCursor = stopIndex > 0 ? batch[stopIndex - 1].serverSeq : since` / `try setCursor(db, newCursor)` / `report.newCursor = newCursor` / `report.stalled = stopIndex < batch.count`.  BridgeScheduler.swift:104 — `status.stalled = report.landing.stalled` (the same signal, surfaced next door).

**Why it matters**

SyncSpec §5's designed graceful stall assumes it 'self-heals when the owing device drains'. Nothing distinguishes a self-healing stall from a permanent one, and the only bit that could is thrown away — so the failure mode is invisible to the author AND unmeasurable by the soak the KnownIssues 'Poison-row isolation / park-and-heal' row (owner 12) says should assess it. That row owns the JAM class; it does not record that the evidence signal is discarded, which is what makes the jam undetectable.

**Verifier**

Traced end to end. SyncEngine.swift:371-374 sets `report.stalled = stopIndex < batch.count` and holds the cursor at `since` when stopIndex == 0. The ONLY two production callers of pull() are SyncScheduler.swift:196 and VaultBootstrap.swift:167, both `_ = try await engine.pull()`; grep over Sources/ + App/ finds no other reader of PullReport at all, and `stalled` appears only in SyncPullTests. runOneRound then executes lastError=nil / lastErrorIsOffline=false / lastSuccessAt=date.now unconditionally, and SyncStatusViews.swift:335 renders that as "Synced <time>". PushReport is discarded the same way, and BridgeScheduler.swift:104 does surface its twin signal, so the pattern is a deliberate one applied next door and not here. TWO MITIGATIONS THE FINDING MISSED, which is why I cut the severity: (a) the field is documented in-code as "the last round that COMPLETED WITHOUT ERROR" — under a stall that is literally true, no exception was thrown; (b) the stall is NOT wholly invisible — DataSafetyModel/SyncSafetyWords.cursorDetail renders "Received everything your account had through change #<cursor>", so a frozen cursor is on a user-facing surface, and that sentence stays honest under a stall (the headline "Everything written on this Mac has reached your account" is about the push half and is also unaffected). The harm therefore needs a PERMANENT poison row, and the permanent-jam class is already an owned KnownIssues row ("Poison-row isolation / park-and-heal", owner 12) whose remedy is to be assessed against soak evidence — soak evidence read from cursors and row counts, not from this in-memory flag, so "unmeasurable by the soak" is overstated. Real, cheap to fix (one line, the BridgeScheduler precedent), narrow in consequence.

---

### P32. Scratch-column picks ARE persisted to UserDefaults, so the dangling-pick notice is scoped out of them on a false premise

`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:1196`

**MINOR** · CONFIRMED · spec-conflict · lens: ops: structural core · confidence 0.90

**Mechanism**

`danglingPick` restricts the J5 archived-pick notice ('say loudly if that take was archived and this is a fallback WITH a button for quick restore') to lens columns, justifying the exclusion with 'a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session'. That premise is false: `TakesColumn.picks` is a stored `Codable` property (TakesModels.swift:33), `TakesViewMemory` wraps `columns` and JSON-encodes them into UserDefaults (TakesModels.swift:59-73), and every scratch pick write calls `saveMemory()` (TakesViewModel.swift:852-854 → :683). Path: pick take T in a scratch column → archive T (TakesViewModel.swift:1171) → quit → relaunch. The column reloads from UserDefaults still naming T; `resolvedTake` (TakesViewModel.swift:487-499) silently falls through to the block's chosen take; `danglingPick` returns nil, so no notice and no Restore button ever render — permanently, not for one session. The model's own docstring contradicts the comment: 'A view-local profile: sparse picks over chosen, persisted only via VIEW MEMORY' (TakesModels.swift:21-23). This is also what makes the promotePicks defect above silent and long-lived rather than a same-minute slip.

**Evidence**

> TakesViewModel.swift:1196 `/// Only LENS columns: a scratch column's picks are view-local` … `/// (\`column.picks\`), never stored, so they cannot dangle across a` … `/// session — recorded rather than silently scoped.` · TakesModels.swift:33 `var picks: [String: String] = [:]` inside `struct TakesColumn: Identifiable, Equatable, Codable` · TakesModels.swift:70 `func save(postID: String, defaults: UserDefaults = .standard) { guard let data = try? JSONEncoder().encode(self) else { return }; defaults.set(data, forKey: Self.defaultsKeyPrefix + postID) }` · TakesViewModel.swift:852 `case .scratch: columns[i].picks[blockID] = variantID; saveMemory()`

**Why it matters**

The author's own 13j J5 ruling was that a fallback pick must announce itself; half the columns that can hold one are silently exempted because of a claim the code does not support. She sees a column showing a take she did not pick, across relaunches, with nothing saying so — and the promote door then copies from that invisible stale pick.

**Verifier**

The comment's factual premise is false, verified directly. TakesModels.swift:28-34: `struct TakesColumn: Identifiable, Equatable, Codable` with `var picks: [String: String] = [:]`; TakesViewMemory (:58-73) wraps `columns` and JSON-encodes them into UserDefaults under `takesViewMemory.<postID>`; TakesViewModel.saveMemory (:683-686) writes it, the init (:49-52) reads it back, and every scratch pick write calls saveMemory (:751-752, :850-854). So a scratch pick DOES survive a relaunch, contradicting TakesViewModel.swift:1196-1198 ("a scratch column's picks are view-local (`column.picks`), never stored, so they cannot dangle across a session") — the model's own docstring at TakesModels.swift:21-23 says "persisted only via VIEW MEMORY". Consequence traced: nothing prunes picks on archive/delete (checked every `picks` site; applyProjection at :433-447 prunes only dead-lens columns and the merge selection), resolvedTake falls through silently (:487-499), and danglingPick returns nil for non-lens columns (:1199-1204) — the notice is rendered only at LensesBoardView.swift:586, so a scratch column shows an unpicked take with nothing saying so, indefinitely. Two corrections to the finding's framing, neither refuting it: (a) the 13j J5 ruling as recorded in the master plan is scoped to a SAVED LENS's pick ("when a saved lens's pick dangles at an archived/deleted take (the core's read-time fallback, `effectiveLensSelection`)"), so scoping the notice to lens columns is not itself a spec violation — what is wrong is the REASON given for it; (b) the surviving defect is therefore a false code comment plus a real but unruled UX gap. MINOR is the right weight; it is not cosmetic, because the same persisted stale pick is the input to the promotePicks defect above.

---

### P33. The Mac's ⌥⌘Z has no in-flight guard, so the A12 destructive-undo confirm can describe a different entry than the one actually undone

`App/Variorum/Variorum/Registry/ShellActions.swift:111`

**MINOR** · CONFIRMED · concurrency · lens: undo/redo · confidence 0.70

**Mechanism**

structuralUndo spawns a Task with no re-entrancy latch and reads the stack twice across two separate runner submissions: pendingUndoWarning (which reads entries.last) and then undo (which reads entries.last again). Two ⌥⌘Z presses landing inside the runner round-trip queue as T1.warn, T2.warn, T1.undo, T2.undo — both warnings are computed against entry E, but T2 undoes E-1. If E is not in the insurance class and E-1 IS, T2 shows no confirm and the discarding undo runs anyway; if the reverse, she is asked about a discard that is not happening. The phone's twin door guards this exactly (MobileUndoDoor.beginUndo: `guard !inFlight else { model.report(Self.anotherIsLanding); return }`), so the Mac is also the drifted copy of a shared rule.

**Evidence**

> ShellActions.swift:111-127 — `func structuralUndo(confirm: ((UndoStack.PendingUndoWarning) -> Bool)? = nil) { let undoStack = session.undoStack; Task { @MainActor in do { let warning = try await session.runner.run { ops in undoStack.pendingUndoWarning(with: ops) } ... let label = try await session.runner.run { ops in try undoStack.undo(with: ops) }` — no inFlight latch anywhere in the function. UndoStack.swift:266 — `guard let entry = lock.withLock({ entries.last })`.

**Why it matters**

Her A12 ruling is that a structural undo which would discard text edited since the operation must confirm first; this is the read-a-projection-then-act-on-a-different-row class the codebase itself names (BlockDeletionPrecondition's R3-1 doc), and it lets the confirm be skipped on exactly the entry it was ruled for. Nothing is unrecoverable (revertStructural's insurance commit at :284 still runs), so the cost is the ruling, not the bytes.

**Verifier**

Read both doors. ShellActions.structuralUndo (App/Variorum/Variorum/Registry/ShellActions.swift:111-137) spawns Task { @MainActor } with no latch and makes two separate awaited runner submissions — pendingUndoWarning then undo — each of which reads entries.last independently (UndoStack.swift:250, :266). MobileUndoDoor.beginUndo (:144-149) guards the identical sequence with `guard !inFlight` and its comment gives this exact reason ("a second press inside the first's suspension would pop a second entry she never asked for"), and confirmPendingUndo re-takes the latch at :181 — so the Mac is the drifted copy of a rule the phone states. The only Mac gate is stack-depth enablement (EditorCommands.swift:331 `.disabled(session?.undoMenuState.topLabel == nil)` and CapabilityRegistry.swift:924 `ctx.undoAvailable`), neither of which changes during the flight. The reachable shape is the no-warning one (E silent, E-1 in the insurance class): both tasks compute nil warnings against E, no modal blocks the MainActor, and the second undo discards E-1's buffer without the A12 confirm. The reverse shape self-limits because confirmDiscardingUndo runs a modal NSAlert. MINOR is right — revertStructural's own insurance commit (:284) still rides inside the undo transaction, so the cost is the ruling being skipped, not the bytes.

---

### P34. BoundarySnapping.settle overrides a deliberate EXACT cut placement when a sentence end sits exactly settlePull units earlier, contradicting its own documented contract

`Sources/VariorumCore/Domain/BoundarySnapping.swift:147`

**NIT** · CONFIRMED · spec-conflict · lens: pure domain functions · confidence 0.95

**Mechanism**

`effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, and the comparator breaks an effective-distance tie toward the EARLIER position. A strong boundary exactly `settlePull` (=2) units before an exact placement therefore also scores 0 and wins the tie. VERIFIED by running the verbatim function: text "Yes. I went home." has word boundaries [0,5,7,12,17] and strong (sentence) boundaries [0,5,17]; `settle(7, in: text, among: [5,7,12])` returns 5 — 7 is an exact word edge and loses. Second sample "Hi. A word here.": `settle(6)` returns 4. Reachable whenever a one-letter word ("I", "A", "O") follows a sentence end, which is constant in English prose. INPUT: the author drags the divide cut to sit exactly before "went". StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) — the ONE snapper for plain divide, the W ceremony's per-take cuts, CutPropagation's seeding and extract's span edges — moves it two units left. OUTPUT: the divide yields "Yes." + "I went home." where she placed "Yes. I" + "went home.", silently. The suite's own comment at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-144 asserts "Cut 9 is exact: the deliberate placement always wins", but its fixture's strong/plain gap is 4, so effectiveDistance(5)=2 and the exact cut wins for a reason that evaporates at gap <= 2 — no test stands at the boundary the invariant lives on.

**Evidence**

> BoundarySnapping.swift:128-131 (the contract) — `/// away than a plain word edge ... without ever overriding a deliberate exact placement, which always wins at distance zero`  ||  BoundarySnapping.swift:145-152 — `let raw = abs(candidate - clamped); return strong.contains(candidate) ? max(0, raw - settlePull) : raw` ... `return da == db ? a < b : da < db`  ||  measured: settle(7, in: "Yes. I went home.", among: [5,7,12]) == 5

**Why it matters**

Divide is one of the three hard-core structural operations, and S4-22's word-edge rule exists so a cut lands where the author put it. A cut silently relocating two characters is exactly the 'the app did something other than what she placed' class 13u item 5 was opened for, and the file's own doc plus the test's own comment both claim it cannot happen — so the next reader trusts a guarantee that does not hold.

**Verifier**

Verified by COMPILING AND RUNNING the real BoundarySnapping.swift (not a replica): for "Yes. I went home." the scanners give word boundaries [0,5,7,12,17] and strong (sentence) [0,5,17], and `settle(7, among: [5,7,12])` returns 5 — the exact word edge at 7 loses. Second sample "Hi. A word here.": `settle(6, among: [4,6,11])` returns 4. Mechanism confirmed at BoundarySnapping.swift:145-152 — `effectiveDistance` returns `max(0, raw - settlePull)` for a strong candidate, so a strong boundary exactly 2 units earlier also scores 0 and takes the tie via `da == db ? a < b`. Production-reachable: StructuralGesturePlanner.snapToInteriorBoundary (App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:200-204) is the only snapper for divideAtCursor, the W ceremony's per-take cuts and CutPropagation, and it passes the raw cut with the full interior word set. The test-comment claim at Tests/VariorumCoreTests/BoundarySnappingTests.swift:143-146 is also as described — its fixture's strong/plain gap is 4, so the exact cut wins there for a reason that evaporates at gap <= 2, and no test stands at the boundary. SEVERITY CORRECTED DOWN to NIT, and this is the part the finding over-reads: the pull is the deliberate S4-22 gentle-settle feature, and the tie-to-earlier rule is stated explicitly in the SAME doc comment (line 138-139) and exercised deliberately by the neighbouring test's cut-8 case. What is actually wrong is the absolutist parenthetical at line 130-131 plus a missing boundary pin; the behavioural consequence is a 2-unit shift confined to the one-character-word-after-a-sentence-end configuration (". I ", ". A "), where relocating the cut to the sentence end is arguably the settle doing its job. Not a user-facing correctness defect of the kind MINOR implies.

---

### P35. `shelf_pins` never self-heals and a deleted book's pin can never be removed, unlike its self-healing sibling `starred` in the same file

`Sources/VariorumCore/Operations/Operations+Appearance.swift:117`

**NIT** · CONFIRMED · drift · lens: ops: lifecycle · confidence 0.90

**Mechanism**

setShelfPinned's public door runs `_ = try liveReading(db, readingID)` first, so once a pinned book is deleted every unpin attempt throws readingNotFound; the internal writer (Operations+Appearance.swift:129-141) only appends or removes the single id it is handed and never prunes; Queries.shelfPins (AppearanceQueries.swift:70-75) returns the raw decoded array with no liveness filter; and the only other writers of the key (insertDailyJournalBook, ensureQuicknotesBook) pin, never unpin. So: pin book R, delete R — R's id is stuck in the stored JSON permanently, and because `setting` is a synced table the growing array is pushed on every subsequent pin change. No wrong render results (ShelfViewModel.ordered orders live `bookshelf` rows by pin order, so dead ids match nothing), which is why this is a NIT.

**Evidence**

> Operations+Appearance.swift:117-122 — `public func setShelfPinned(_ readingID: String, pinned: Bool) throws { try database.write { db in _ = try liveReading(db, readingID); try setShelfPinned(db, readingID, pinned: pinned) } }`
> AppearanceQueries.swift:70-75 — `public static func shelfPins(_ db: Database) throws -> [String] { ... return (try? JSONDecoder().decode([String].self, from: Data(json.utf8))) ?? [] }` (no liveness filter)
> Contrast, Operations+Appearance.swift:164-167 — `/// 3. **EVERY WRITE SELF-HEALS.** It rewrites the list `Queries.starred` would return — i.e. live targets only`

**Why it matters**

Two sibling list-valued settings written twenty lines apart in one file have opposite hygiene: `starred` prunes dead targets on every write precisely so its cap counts only what she can see; `shelf_pins` accumulates dead ids with no door able to remove them. It is harmless today only because every consumer joins against live rows — the next face that reads `shelfPins` directly (a pin count, a reorder UI) inherits a list that lies about its own length.

**Verifier**

Traced and it holds exactly as written. Operations+Appearance.swift:117-122 — the public setShelfPinned runs `_ = try liveReading(db, readingID)` first, and Operations.swift:85-90 shows liveReading throws readingNotFound for any row with deletedAt != nil, so once a pinned book is deleted every unpin attempt throws. The internal writer (129-141) only appends/removes the one id handed to it and never prunes. Queries.shelfPins (AppearanceQueries.swift:70-75) decodes the raw array with no liveness filter ('pins are presentation, never truth' — fail-open on malformed JSON only). I grepped every writer of the key: only setShelfPinned itself plus insertDailyJournalBook (Operations+Container.swift:228) and the quicknote book ensure (Operations+Quicknote.swift:121), both of which PIN — no path unpins on delete, and deleteReading is not among the callers. The contrast with `starred` is exactly as quoted (Operations+Appearance.swift:164-167, 'EVERY WRITE SELF-HEALS… live targets only'). NIT is the right rating and the finding says so honestly: ShelfViewModel.ordered (lines 81-96) walks pins and keeps only ids matching a live `bookshelf` row, and the mobile shelf reads the same way, so a dead id renders nothing. Corroborating evidence the class is already known but unfixed at the op: MobileTutorialSeeder.swift:179 unpins doomed books BEFORE deleting them, and notes/plans/mobile-parity-round.md:2321 pins that workaround with 'Cleanup unpins doomed books so shelf_pins never accrues dead ids across restores' — a caller-side workaround for exactly this hole, which is the drift the finding names rather than a documented acceptance of it.

---

### P36. A failed re-read in `applyPendingIfClean` discards the deferred projection instead of restoring it, while both sibling guards restore

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:803`

**NIT** · CONFIRMED · error-swallowing · lens: Mac editor feature · confidence 0.60

**Mechanism**

`applyPendingIfClean` sets `pendingProjection = nil` before spawning the read task; the `guard let fresh = try? await session.database.read(...) else { return }` arm then returns without restoring it, whereas the two guards immediately after both write `pendingProjection = fresh` on their failure paths. If the read throws — the plausible post-13p trigger is a re-lock / Lock Now closing the keyed store while a settle is in flight — the externally-changed projection (a sync-applied conflict variant, a chosen-variant flip from another surface) is discarded and the surface keeps showing pre-change content until some later store write produces a fresh observation delivery.

**Evidence**

> EditorViewModel.swift:798-805 — `pendingProjection = nil` … `guard let fresh = try? await session.database.read({ [postID] in try Queries.renderPost($0, containerID: postID) }) else { return }`, versus lines 806-813 — `guard !autosave.isDirty, !mintInFlight, !structuralInFlight else { pendingProjection = fresh; return }` and `guard generation == storeWriteGeneration else { pendingProjection = fresh; applyPendingIfClean(); return }`.

**Why it matters**

The surrounding machinery is built on the rule that a deferred projection is never lost — every other exit restores the marker. The asymmetry is unambiguous even though the trigger frequency is unknown; low confidence is on how often the read actually throws, not on the code path.

**Verifier**

The code asymmetry is exactly as described and unambiguous. EditorViewModel.swift:795-816: the method sets `pendingProjection = nil` before spawning the read task; the failure arm is `guard let fresh = try? await session.database.read(...) else { return }` — a bare return with no restore — while the two guards immediately below both write `pendingProjection = fresh` before returning (the busy guard and the generation-fence guard, which additionally re-calls `applyPendingIfClean()`). So on a thrown read the deferred marker is dropped and nothing re-arms it; the surface then waits on the next ValueObservation delivery, which only fires on a further store change. Two honest qualifications that hold the severity at NIT rather than higher: the discarded value is a STALE photograph that would have been re-fetched anyway (so restoring it costs nothing but gains only a retry), and the plausible post-13p trigger the finding names — a re-lock closing the keyed store — would very likely also error the observation itself (EditorViewModel.swift:622-624 sets `statusMessage = "Note observation failed"`), which is a louder failure than the lost marker. The Task is unstructured with no cancellation source, so `try?` is swallowing a store error rather than a cancellation. NIT confirmed: a real one-line asymmetry against the surrounding machinery's own never-lose-the-marker rule, with narrow and mostly-moot consequence.

---

### P37. The tray's ARCHIVED listing is silently truncated at 500 while its two sibling listings render truncation markers

`App/Variorum/Variorum/Features/Tray/TrayPanel.swift:400`

**NIT** · CONFIRMED · drift · lens: Mac takes/compare/canvas · confidence 0.85

**Mechanism**

`TrayViewModel.start` fetches all three listings with the standing probe row (`limit: Self.window + 1`, window = 500 at :224). `adopt` then flags two of them and not the third: `deletedTruncated = snapshot.deleted.count > Self.window` (:398) and `(takes, takesTruncated) = TrashListing.windowed(snapshot.takes, window: Self.window)` (:402) both survive into the view as `truncation("deleted")` at :777 and :818 — but `archived = Array(snapshot.archived.prefix(Self.window))` (:400) discards the probe row and everything past it with no flag and no marker anywhere in the view. A note holding more than 500 archived blocks therefore shows exactly 500 with nothing saying more exist, on a recovery surface whose entire job is to audit what a note has set aside. The probe row is fetched and thrown away, which is what marks this as an omission rather than a decision.

**Evidence**

> TrayPanel.swift:398-403 — `deletedTruncated = snapshot.deleted.count > Self.window` / `archived = Array(snapshot.archived.prefix(Self.window))` / `(takes, takesTruncated) = TrashListing.windowed(...)`; `grep -n "Truncated" TrayPanel.swift` yields only `deletedTruncated` (:228) and `takesTruncated` (:259).

**Why it matters**

KnownIssuesAndTechDebt.md's "Bounded view windows show markers, not more" row states the standing rule as "visible truncation markers (never a silent cut; probe-row +1 so exact-window readings don't false-positive)". A recovery surface that quietly hides rows is the one place a silent cut reads as data loss. Reachability at 500 archived blocks in a single note is remote, hence NIT.

**Verifier**

Verified in TrayPanel.swift. All four arms fetch with the probe row (`limit: Self.window + 1` at :363, :365, :367, :377; window = 500 at :224). `adopt` (:396-403) sets `deletedTruncated = snapshot.deleted.count > Self.window` and `(takes, takesTruncated) = TrashListing.windowed(...)`, but `archived = Array(snapshot.archived.prefix(Self.window))` with no flag — the probe row is fetched and discarded. `grep -n 'truncation('` yields only :777 (deleted) and :818 (takes) plus the builder at :872; the ARCHIVED section (:724-739) renders `ForEach(model.archived)` and an empty-state line, nothing more. No note in the repo records the omission as deliberate (the only nearby record, the A6 ladder comment at :359-362, is about bounding both listings in SQL, which was done). So it is a real drift from the standing rule quoted in KnownIssuesAndTechDebt.md's "Bounded view windows show markers, not more". NIT is correct: 500 archived blocks in one note is remote, and nothing is lost — only unlisted.

---

### P38. StoreBackup.run has no single-flight latch — two forced runs in the same second write and prune the same backup file

`App/Variorum/Shared/StoreBackup.swift:143`

**MINOR** · CONFIRMED · concurrency · lens: concurrency & threading · confidence 0.70

**Mechanism**

`run(force:)` spawns `Task.detached { performRun(...) }` with no in-flight guard, and two independent trigger sources reach it: the hourly `start()` loop → `backupIfDue()` (:112-120), which is outside any UI state, and the UI, whose `busy` latch does not cover every door — `DataSafetyModel.setInsurance` calls `backup.backUpNow()` with no `busy` guard (DataSafetyModel.swift:125-136) and its Toggle is not `.disabled(model.busy)` (DataSafetyPane.swift:159-160), unlike the Back Up Now button (:87). The destination filename stamp is second-granular (`"yyyy-MM-dd-HHmmss"`, :478), so two parallel runs in the same second compute the SAME path. Each then (a) opens its own DatabaseQueue at that path and runs sqlite3_backup into it (AppDatabase.swift:189-196); (b) runs `integrityCheck`, which executes `PRAGMA journal_mode = DELETE` and deletes `url + "-wal"` / `url + "-shm"` (:401-406) while the other run may still be writing that file; (c) runs `prune(directory:keep:)` (:440, :446-452) — both list, both compute the same doomed set, both `removeItem(at:)`, and the loser throws NSCocoaErrorDomain 4 out of `performBackupIfDue`.

**Evidence**

> StoreBackup.swift:143-157 — `private func run(force: Bool) async { ... let record = await Task.detached(priority: .utility) { ... }.value` (no latch). StoreBackup.swift:437-440 — `let url = directory.appendingPathComponent("\(filePrefix)\(stampFormatter.string(from: now)).\(fileExtension)"); try database.backup(to: url); try prune(directory: directory, keep: configuration.keep)`. DataSafetyModel.swift:131-132 — `if enabled, let backup { let record = await backup.backUpNow() }` with no `guard !busy` (contrast :219, :239, :249). DataSafetyPane.swift:159-160 — `set: { on in Task { await model.setInsurance(on) } }))` `.disabled(model.destination == .unset && !model.insuranceEnabled)`.

**Why it matters**

The prune collision propagates out of `performBackupIfDue`, so `primary.outcome = .failed` and `lastError` is set (:204-207) for a run whose snapshot actually succeeded — a false "the mechanism is broken" reading on the exact face 13l built to make backup freshness trustworthy. The sidecar deletion in `integrityCheck` can also land on a file the sibling run is still writing, producing a bad snapshot at the moment the user is deliberately asking for one.

**Verifier**

Every quoted fact checks out. StoreBackup.swift:143-162: `run(force:)` captures `let stamp = now()` and spawns a bare `Task.detached { performRun(...) }` with no in-flight guard anywhere in the file (grepped for latch/in-flight/reentrancy language — none). The filename is second-granular (`"yyyy-MM-dd-HHmmss"`, :477-478) and is built from that entry-time stamp (:437-438), so two runs entering in the same UTC second compute the SAME path, then each opens its own `DatabaseQueue` at it and runs `writer.backup(to:)` (Sources/VariorumCore/Persistence/AppDatabase.swift:189-196). `prune` (:446-452) is unguarded oldest-first `removeItem`, and `keep = 14` (:47), so on any install older than two weeks both runs compute the same doomed set and the loser's `removeItem` throws out of `performBackupIfDue` into the `catch` at :516-ish, setting `primary.outcome = .failed` and `lastError` (:159-161) for a run whose snapshot succeeded. The un-latched door is real: DataSafetyModel.swift:125-136 `setInsurance` calls `backup.backUpNow()` with neither `guard !busy` nor `busy = true` (contrast :219, :239, :249), and its Toggle (DataSafetyPane.swift:158-160) carries only `.disabled(model.destination == .unset && ...)`, so 'Back Up Now' (:87 `.disabled(model.busy)`) stays live while the toggle's forced run is in flight. `integrityCheck`'s sidecar deletion (:395-402) is as described. MINOR is right: it needs two forced acts inside one second, and the worst outcomes are a false 'failed' receipt on the freshness face and a possibly-bad concurrent snapshot beside good ones.

---

## T4 — Architecture, drift & dead code

Shape problems with a named consequence: where the next change lands wrong, or where one rule lives in two places and will diverge silently.

### P39. Feature modules call each other directly — 20 mutual pairs, including a hard Library↔Pool view-model cycle and a sibling view model constructed inline

`App/Variorum/Variorum/Features/Pool/PoolPostsView.swift:240`

**MINOR** · CONFIRMED · architecture · lens: architecture conformance · confidence 0.90

**Mechanism**

CLAUDE.md binds: 'One feature = one self-contained module... Cross-feature interactions route through parent composition, never feature-to-feature calls.' Measured over Features/*/ with comment lines blanked and generic type names excluded: 20 mutually dependent feature pairs. Confirmed violations: (a) Editor/WriteTakesPanel.swift:51 CONSTRUCTS a sibling feature's view model inline — `TakesViewModel(session:postID:)` — so Editor owns Takes' model lifecycle; (b) Pool/PoolPostsView.swift:240,246 calls methods directly on LibraryViewModel; (c) a hard type cycle — Library/SidebarView.swift:105 holds `let pool: PoolViewModel` while Pool/PoolPostsView.swift:127 holds `let library: LibraryViewModel`; (d) NoteDeletion, an app-wide act, is homed at Features/Library/NoteDeletion.swift:90 and reached from four features (Takes/TakesBottomBar.swift:406,411; Pool/PoolPostsView.swift:179,253; Editor/CommitBar.swift:301,311). Consequence: no feature can be changed, tested, or reviewed in isolation — a lifecycle change to PoolViewModel lands at a Library call site a Pool-scoped reviewer never opens, and the reverse. For (d) specifically, the next door needing note deletion must either import a feature or copy the act.

**Evidence**

> Pool/PoolPostsView.swift:240 — `Task { await library.duplicateAsVersion(postID: item.postID) }`; :246 — `Task { await library.archive(postID: item.postID) }`; :127 — `let library: LibraryViewModel`. Library/SidebarView.swift:105 — `let pool: PoolViewModel`. Editor/WriteTakesPanel.swift:51 — `_model = State(initialValue: TakesViewModel(session: session, postID: postID))`.

**Why it matters**

The module boundary the canon declares does not exist at runtime or at review time. Note the asymmetry this already produced: mobile round 2 batch 4 hoisted the deletion WORDS (RecoveryCopy, StructuralUndoCopy) into Shared/ precisely to end this drift class, but the deletion ACT stayed inside Features/Library — so Shared/, which exists and is the correct home, holds the copy while the behaviour lives in a feature. That is how the phone ended up with three independent deleteContainer call sites against the Mac's one consolidated act (all three do currently honour the flush obligation — verified — but nothing structural keeps them doing so).

**Verifier**

Every cited line is real. WriteTakesPanel.swift:51 does `_model = State(initialValue: TakesViewModel(session:postID:))` — Editor constructing Takes' VM. PoolPostsView.swift:127 holds `let library: LibraryViewModel` and calls `library.duplicateAsVersion` (:240) and `library.archive` (:246); SidebarView.swift:105 holds `let pool: PoolViewModel` — the type cycle is real. CLAUDE.md/AppSpec §2's rule is quoted correctly. THREE CORRECTIONS. (a) Both cycle halves ARE wired by parent composition — RootView.swift:133 and :557 are the only construction sites — so what is violated is the 'never feature-to-feature calls' half, not the composition half. (b) The class is already documented: notes/plans/phase-13b-stage0-architecture-survey.md §8.1 'Cross-feature coupling' enumerates it including WriteTakesPanel's TakesViewModel ownership by name, and 13b acted on one instance (the plan's Canvas row said 'stop calling TakesViewModel.message(for:) cross-feature' — grep confirms CanvasView no longer does). So already_known is wrong. (c) Item (d) is REFUTED on its merits: NoteDeletion is a static act namespace whose own header documents 'Four doors reach this act' and why it is one file; the App target is a single Swift module, so no import cost exists and the objection reduces to folder placement. Severity down to MINOR: no invariant (I/P/S) is violated and no user-visible behaviour is wrong; this is maintainability, and the claim 'no feature can be changed, tested, or reviewed in isolation' is overstated.

---

### P40. Shelf ORDER and smart-book tag brains are a byte-identical Mac/mobile fork, and are absent from KnownIssues' "eight brains" enumeration that claims to be complete

`App/Variorum/VariorumMobile/Features/Shell/MobileShelfFaces.swift:101`

**MINOR** · CONFIRMED · drift · lens: mobile app · confidence 0.90

**Mechanism**

`MobileShelfFaces.ordered(books:pins:)` (MobileShelfFaces.swift:101-114) and `ShelfViewModel.ordered(books:pins:)` (App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift:81-96) are the same statements in the same order — pins collected in pin order, then `rest` split on `profile == "journal"` and each half sorted by `reading.name`. Neither delegates to the other; neither lives in App/Variorum/Shared/ or VariorumCore/Domain. The same holds for `MobileShelfFaces.tagPaths(for:curatedTags:)` (:44-54) vs `ShelfViewModel.tagsColumn(for:)` (:103-112) — identical `querySpec` JSONDecoder walk and `(spec.tagsAll ?? []) + (spec.tags ?? [])`. KnownIssuesAndTechDebt.md's forked-brain row asserts "THE CURRENT ENUMERATION is the parity inventory's EIGHT-brain table … every symbol grep-verified 2026-08-21" and lists ThemeStore, applyTypedPath, CalloutPalette, CalloutMenu.rows, the five deletion-copy homes, TakeClipboard, BlockSelection, TakesReplacePlan — neither shelf symbol appears, so these two sit under no owner and falsify the row's completeness claim. Concrete divergence path: the master plan's 13i row carries her ruling "CUSTOM SHELF ORDER MUST BE ADDED"; a phase editing `ShelfViewModel.ordered` to honour a stored custom order leaves `MobileShelfFaces.ordered` on R38's pin-then-journal-then-name rule, and the phone's shelf silently disagrees with the Mac's about the order of the same books, with a green suite on both sides.

**Evidence**

> MobileShelfFaces.swift:101 `static func ordered(books: [Queries.ShelfBook], pins: [String]) -> [Queries.ShelfBook]` — body identical to ShelfViewModel.swift:81 `nonisolated static func ordered(books:pins:)`, both ending `return pinned + journals + others`. MobileShelfFaces.swift:46 and ShelfViewModel.swift:105 both: `guard let json = book.reading.querySpec, let spec = try? JSONDecoder().decode(Queries.SmartQuerySpec.self, from: Data(json.utf8)) else { return [] }; return (spec.tagsAll ?? []) + (spec.tags ?? [])`.

**Why it matters**

MobileSoul §3's named drift class, on a rule the author has already ruled will change at 13i. The KnownIssues row's remedy is always a HOIST, never a patch — but a brain nobody knows is forked cannot be hoisted, and the row's own enumeration is what the next phase will read.

**Verifier**

The code claim checks out exactly. `MobileShelfFaces.ordered(books:pins:)` (MobileShelfFaces.swift:99-112) and `ShelfViewModel.ordered(books:pins:)` (ShelfViewModel.swift:81-95) are the same statements in the same order, both ending `return pinned + journals + others`; neither delegates, neither lives in App/Variorum/Shared/ or VariorumCore. `MobileShelfFaces.tagPaths` (:41-54) and `ShelfViewModel.tagsColumn` (:103-113) share the identical `SmartQuerySpec` decode + `(spec.tagsAll ?? []) + (spec.tags ?? [])`, differing only in where the curated aggregate comes from. Both sides carry their own pins (MobileShellTests.swift:99; the Mac's own) and there is no cross-platform drift pin. Two corrections that pull the severity down hard. (1) The completeness claim is over-read: the parity inventory's table is scoped "Building the faces above adds these" (mobile-round-2-parity-inventory.md, §4(c) preamble) — it enumerates the brains that ROUND's faces would need, not every fork in the tree. (2) The KnownIssues row owns the CLASS with a named owner, and its standing rule — "any Mac phase touching one of these brains hoists it THEN" — is what would fire at 13i, so "sits under no owner" overstates it; what is true is that these two symbols are untracked. Nothing behaves wrongly today and the divergence is contingent on a future phase, so this is debt, not a MAJOR.

---

### P41. Read's markdown-paragraph brain and the link-scheme guard are duplicated on the phone, against MarkdownLink's own "one rule, one guard, one door" declaration

`App/Variorum/VariorumMobile/Features/Read/MobileReadPage.swift:131`

**MINOR** · CONFIRMED · drift · lens: mobile app · confidence 0.85

**Mechanism**

`MobileReadPage.openableLink(_:)` (MobileReadPage.swift:131-141) re-implements `MarkdownLink.openable(_:)` (App/Variorum/Variorum/Features/Formatting/MarkdownLink.swift:31-39) statement for statement, including its own `openableSchemes: Set<String> = ["http", "https"]` at :129. `MobileReadPage.paragraphs(of:codeTint:)` (:76-106) and `container(for:codeTint:)` (:108-124) are likewise byte-identical to `FlowParagraph.paragraphs`/`container` (App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift:209-269), as is `MobileReadPage.Paragraph.indent` vs `FlowParagraph.indent`. MarkdownLink's header states the invariant this breaks: "Three surfaces open links and they must agree … One rule, one guard, one door" and "Widening this is one line" (QUESTIONS #50 is a build-time call). There are now four surfaces and two rules. Concrete divergence: a phase that widens the Mac set (say to `mailto`) changes MarkdownLink.openableSchemes and the Mac's three surfaces follow; MobileReadPage keeps `["http","https"]`, so the SAME stored note renders its link as tappable on the Mac and as inert text on the phone, with nothing failing. The same shape applies to any change in the run-walk or emphasis mapping in `container`.

**Evidence**

> MobileReadPage.swift:129-141 — `static let openableSchemes: Set<String> = ["http", "https"]` … `guard !trimmed.isEmpty, let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(), openableSchemes.contains(scheme), url.host?.isEmpty == false else { return nil }` — identical to MarkdownLink.swift:33-38. MarkdownLink.swift:8-9 — "Three surfaces open links and they must agree … One rule, one guard, one door."

**Why it matters**

`MarkdownLink.openable` is pure Foundation (only the `open` face needs AppKit), so the guard is the hoistable half and the file itself already says it must live once. Same drift class as finding 3, and likewise outside KnownIssues' enumeration.

**Verifier**

Verified in both files. `MobileReadPage.openableSchemes` + `openableLink` (MobileReadPage.swift:129-141) reproduce `MarkdownLink.openableSchemes` + `openable` (MarkdownLink.swift:27-39) statement for statement — same trim, same scheme set, same `url.host?.isEmpty == false`. `MobileReadPage.paragraphs(of:codeTint:)` (:75-105) and `container(for:codeTint:)` (:107-123) likewise reproduce `FlowParagraph.paragraphs`/`container` (ReadingFlowView.swift:209-268) including the concatenation walk and the emphasis→`InlinePresentationIntent` mapping; only the final line differs (`openableLink(raw)` vs `MarkdownLink.openable(raw)`). Both consume the shared `MarkdownRendering`, so only this presentation layer is forked. The guard half is pure Foundation (only `open(_:)` needs AppKit), so it is hoistable, and the phone's own comment concedes the shape ("`MarkdownLink.openable`'s rule, mirrored"). Same class as finding 3, and MINOR is the right size: the drift is latent, no user-visible wrong behavior today. Note the finding slightly over-reads MarkdownLink's header — "three surfaces" enumerates the MAC surfaces of one app target, not a cross-platform invariant.

---

### P42. The segmentation-mode → crystallization-kind rule is written out five times across the two platforms with nothing pinning them together

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1343`

**NIT** · CONFIRMED · drift · lens: Mac editor feature · confidence 0.80

**Mechanism**

`CrystallizationPlanner` owns the planning but not the kind selection, so the mapping is duplicated at EditorViewModel.swift:559-560 (`finalizeWork`), :1295 (`idleMintTail`), :1343-1344 (`crystallizeIfNeeded`), and MobileEditorViewModel.swift:1619 and :1662-1663. All five are byte-identical today. A rule change (a new segmentation mode, or a ruling that the idle mint behaves differently under `one_block`) landing in `crystallizeIfNeeded`'s default arm leaves the teardown and idle-mint sites — and both phone sites — on the old rule, and the platforms crystallize differently with nothing announcing it.

**Evidence**

> EditorViewModel.swift:1343-1344 — `let kind: CrystallizationPlanner.Kind = forcedKind ?? (bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing))`; EditorViewModel.swift:1295 — `crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))`; EditorViewModel.swift:559-560 — `let kind: CrystallizationPlanner.Kind = mode == .oneBlock ? .oneBlock : .idle(.paragraph)`; MobileEditorViewModel.swift:1619 and :1662-1663 repeat both expressions verbatim.

**Why it matters**

This is the forked-brain class KnownIssues already tracks ("Mac app-local brains are forked against mobile siblings"), but this brain is not in that row's eight-item enumeration, so no sweep will find it. The standing fix is a hoist, not a patch.

**Verifier**

All five sites verified verbatim: EditorViewModel.swift:559-560 (`mode == .oneBlock ? .oneBlock : .idle(.paragraph)` in the teardown mint), :1295 (`crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))` in the idle-mint tick), :1342-1344 (`forcedKind ?? (bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing))`), and the phone's byte-identical twins at MobileEditorViewModel.swift:1619 and :1661-1663. `CrystallizationPlanner` owns the planning; the kind SELECTION is duplicated. Byte-identical today, so there is no wrong behavior to point at — this is a genuine drift risk in exactly the class KnownIssues tracks ("Mac app-local brains are forked against mobile siblings") and is absent from that row's eight-item enumeration, so no scheduled sweep would find it. NIT is the correct rating: real, zero present consequence, and the standing remedy (hoist to Shared/) is cheap.

---

### P43. `EditorViewModel.fanAction` and two `FanPanelState` fields are dead production code, reached only by a test, and every fan-panel open pays a pointless store read

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:2447`

**MINOR** · CONFIRMED · dead-code · lens: Mac takes/compare/canvas · confidence 0.95

**Mechanism**

Sitting 9 (R87) retired the FanPanel: the only presenter is EditorView.swift:108-112, `.sheet(item: $model.fanPanel) { panel in WriteTakesPanel(session: session, postID: postID, blockID: panel.blockID) }`, which reads ONLY `panel.blockID` and drives every act through its own `TakesViewModel`. But `loadFan` still performs an async `Queries.blockFan` read and an index walk purely to populate `FanPanelState.variants` and `.chosenVariantID` (EditorViewModel.swift:2338-2347) — `grep -rn "FanPanelState" App/Variorum` returns exactly three hits (the property :106, the struct :217, this construction :2346) and neither field is ever read. `fanAction` (:2447) plus `enum FanAction` (:2480) — roughly 45 lines dispatching eight distinct operations, each `Task { await autosave.flushNow(); ... }` — has one caller in the entire tree: VariorumTests/EditorSessionTests.swift:721 (`refusalsSurfaceAsMessages`), which must hand-construct `h.model.fanPanel = .init(blockID:..., variants: [], chosenVariantID: ...)` first precisely because no UI path can produce it. So the suite guards a door that cannot be opened from the app, and the live delete-take refusal wording is actually produced by a different road (`WriteTakesPanel` → `TakesViewModel.deleteTake` → `OpsRefusalCopy.message`).

**Evidence**

> EditorViewModel.swift:2338-2347 — `let variants = try await session.database.read { db in try Queries.blockFan(db, blockID: blockID) }; let chosen = index.entries.first { $0.blockID == blockID }?.variantID; fanPanel = FanPanelState(blockID: blockID, variants: variants, chosenVariantID: chosen)`. EditorView.swift:112 — `WriteTakesPanel(session: session, postID: postID, blockID: panel.blockID)`. EditorSessionTests.swift:719-721 — `h.model.fanPanel = .init(blockID: slots[0].blockID, variants: [], chosenVariantID: slots[0].variantID); h.model.fanAction(.delete(slots[0].variantID!))`.

**Why it matters**

Forty-five lines of ops-calling code that no user can reach, kept alive only by the test that exercises it, is the drift surface a future change will edit believing it ships — and the test reads as coverage of the take-delete refusal path while covering a retired one. The unused read also costs an async store round-trip on every fan-panel open.

**Verifier**

Verified by grep over the whole app tree. `fanAction` (EditorViewModel:2447) and `enum FanAction` (:2480) have exactly one caller in the repo: VariorumTests/EditorSessionTests.swift:721, which must hand-construct `h.model.fanPanel = .init(blockID:…, variants: [], chosenVariantID: …)` first. The only presenter is EditorView.swift:108-112, whose comment says "Sitting 9 (R87): the FanPanel is retired" and which passes only `panel.blockID` to `WriteTakesPanel`. `FanPanelState.variants` and `.chosenVariantID` are written at :2346 and read nowhere in production (`chosenVariantID` grep returns only the struct field, the construction, and unrelated Compare/mobile symbols; `variants` is read only in FocusHandoffTests:206). `openFan` IS a live road (button at EditorView.swift:667 plus the routed command at :2331), so `loadFan`'s async `Queries.blockFan` read does run on a real gesture purely to fill unread fields. One correction to the finding's framing, which does not change the verdict: `FanPanelState` itself is not dead — the sheet's `item:` binding uses it, and `blockID`/`id` are live; only the two fields and `fanAction` are. Severity MINOR is right: no user-visible consequence, but ~45 lines of ops-calling code no UI can reach, guarded by a test that reads as coverage of a refusal path the live road (WriteTakesPanel → TakesViewModel.deleteTake) actually produces.

---

### P44. UndoStack grows unbounded for the app session's life and its removeAll() has no production caller

`Sources/VariorumCore/Operations/UndoStack.swift:304`

**NIT** · CONFIRMED · dead-code · lens: undo/redo · confidence 0.90

**Mechanism**

One UndoStack is constructed per AppSession (AppSession.swift:494) and nothing ever trims it: entries has no cap, no age-out and no clear door. `removeAll()` is public but its only callers are UndoStackTests.swift:419 and :498 — dead in production. Entries retain full text: TextPreImage holds both `text` and `postOpText` for each touched variant, and MintedPreImage.birthTexts holds the whole working_text of every minted variant, which for divideDuplicating on a fanned block is every take duplicated onto BOTH successors. A long writing session therefore accumulates two copies of every structurally-touched buffer with no ceiling and no way for the user or the app to release them.

**Evidence**

> UndoStack.swift:304-310 — `public func removeAll() { lock.withLock { entries.removeAll(); redoEntries.removeAll() } ; notifyChange() }`; `grep -rn "removeAll()" App Sources` finds callers only inside UndoStack itself. AppSession.swift:494 — `let undo = UndoStack()`. UndoStack.swift:214-218 — `self.birthTexts = Dictionary(uniqueKeysWithValues: variants.map { ($0.id, $0.workingText) })`.

**Why it matters**

Per-act cost is bounded by the edit so P1's letter holds, but the accumulation is not bounded by anything, and the one API that could bound it is unreachable from the app — so this is both retained memory with no ceiling and a public entry point that no production code can reach.

**Verifier**

Both halves verified. One UndoStack per AppSession (App/Variorum/Shared/AppSession.swift:494), `entries` has no cap, no age-out and no production clear door; the sole non-register clear is the redo-side removeAll inside undo (:276). `public func removeAll()` (:304-310) is called only from Tests/VariorumCoreTests/UndoStackTests.swift:419,498, RedoStackTests.swift:567 and PoolDragCopyTests.swift:163 — a grep for removeAll() across all of Sources/ and App/ returns no other UndoStack caller, so the public API is unreachable from either app. Retention is as described: TextPreImage carries both text and postOpText (:162-166) and MintedPreImage.birthTexts carries every minted variant's whole working_text (:213-217). Confirming at NIT as filed: per-act cost stays bounded by the edit so P1's letter holds, the stack is session-scoped and never persisted by design, and blocks are paragraph-sized — the accumulation is a real ceiling-less retention plus a genuinely dead public entry point, not a defect a user meets.

---

### P45. BoundarySnapping.snap has zero production callers, yet divide's op doc names it as the boundary contract instead of the settle rule that actually ships

`Sources/VariorumCore/Domain/BoundarySnapping.swift:116`

**NIT** · CONFIRMED · dead-code · lens: pure domain functions · confidence 0.90

**Mechanism**

`grep -rn --include="*.swift" "BoundarySnapping.snap\|\.snap(" Sources App` returns exactly two hits and BOTH are comments (Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). The only executable callers are BoundarySnappingTests.swift:178-195. Every shipped door snaps through `settle` instead (StructuralGesturePlanner.swift:200-204, 295-303, 335-338), and the two functions genuinely disagree: `snap` is plain nearest over a Granularity with no pull, `settle` takes an explicit candidate list and applies settlePull, so they return different offsets at every cut where a strong boundary is within 2 units (finding 2's class). INPUT: a session reads `divide`'s doc to learn what a legal cut is. OUTPUT: it learns a rule no door enforces, and `snap` stays permanently green because its own tests are its only users — a public API kept alive solely by its test.

**Evidence**

> BoundarySnapping.swift:116 — `public static func snap(_ cut: Int, in text: String, granularity: Granularity) -> Int {`  ||  Operations+Structural.swift:181 — `/// deliberately the editor's contract (\`BoundarySnapping.snap\`) — the`  ||  StructuralGesturePlanner.swift:202-204 — `let interior = BoundarySnapping.boundaries(in: text, granularity: .word).filter { ... }; return BoundarySnapping.settle(cut, in: text, among: interior)`

**Why it matters**

The docs are canon here (CLAUDE.md: if code conflicts with the spec, call it out). An op-level doc naming a dead function as its contract is the drift class the project's own review discipline exists to catch, and the dead public function will keep passing tests that prove nothing about shipped behaviour.

**Verifier**

Verified by grep over Sources, App (both Variorum and VariorumMobile) and Tests: `snap(` matches exactly ONE definition (BoundarySnapping.swift:116) and thirteen call sites, ALL of them in Tests/VariorumCoreTests/BoundarySnappingTests.swift:180-213. Zero production callers, on either platform. The only other repo mentions of the symbol are two doc comments (Sources/VariorumCore/Operations/Operations+Structural.swift:181 and StructuralGesturePlanner.swift:15). I read the divide doc in full: line 180-183 says boundary discipline is 'deliberately the editor's contract (`BoundarySnapping.snap`)' — and the editor's actual contract is `settle`, per the planner's own three call sites (StructuralGesturePlanner.swift:204, 295-303, 336-338) and BoundarySnapping's own class doc at line 72-73 ('`settle(_:in:among:)` is the one snap brain'). The two functions genuinely differ: `snap` is plain nearest over a Granularity with no pull, `settle` takes a candidate list and applies settlePull, so they disagree at exactly finding 2's class. Real doc drift left by the S4-22 cut redesign, with a public function whose only exercisers are its own tests. NIT is the right severity — no runtime consequence, only a stale contract name a future session would trust.

---

### P46. AppSpec §7's setting-seed comment still says idle_commit_hours = 24; the shipped seed is 2

`Sources/VariorumCore/Persistence/Migrations.swift:790`

**NIT** · CONFIRMED · drift · lens: persistence+migrations · confidence 0.95

**Mechanism**

seedV1Settings inserts ('idle_commit_hours', '2'), and v1_13_savepoint_backstop moves existing stores off '24'. notes/AppSpec.md §7's setting DDL block still carries `-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','24')`. The 24 -> 2 ruling (13j, J11) is recorded in OverallModel.md §3 and in the v1_13 migration comment, so this is a stale line rather than an open question. A reader cross-checking the DDL against §7 — which CLAUDE.md names as the single source of design truth, and which is exactly what a schema review is instructed to do — reads a default value the store has not had since 13j.

**Evidence**

> Migrations.swift:786-792 — `INSERT INTO setting (key, value) VALUES ('default_segmentation', 'paragraph'), ('major_revision_threshold', '0.8'), ('idle_commit_hours', '2');`  ||  Migrations.swift:775-780 — "`idle_commit_hours` seeds at 2, not AppSpec §7's original 24 (Phase 13j, J11 ...)"  ||  notes/AppSpec.md §7 — "-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','24')"

**Why it matters**

This project treats canon-vs-code divergence as a first-class defect ("If code conflicts with the spec/model, call it out explicitly"). The migration's own comment already knows §7 is stale, which means the closeout that made the change updated OverallModel but not AppSpec — a one-line correction, but the kind that compounds because §7 is the file every schema-touching session reads first.

**Verifier**

Verified both sides. Migrations.swift:780-792 seeds `('idle_commit_hours', '2')` and its own comment names §7 as stale, citing the 13j J11 ruling and v1_13_savepoint_backstop for existing stores; MigrationTests.settingsAreSeeded carries an annotated pin at the 2 h value. notes/AppSpec.md:359 still reads `('idle_commit_hours','24')`, and the drift is in fact WIDER than the finding says — AppSpec §9's idleAutoCommit entry (line 419) also still reads "(setting, default 24)", while OverallModel.md:34 correctly records the 24 h → 2 h drop. So the 13j closeout updated OverallModel and left AppSpec stale in two places. No behavioral consequence; purely canon-vs-code drift, which this project does treat as a first-class defect but which costs nothing until a reader trusts §7 over the migration. NIT is correct.

---

## T5 — Test-suite integrity — pins that cannot fail

Tests that would not go red if the thing they name broke. These matter disproportionately here because this project's whole review doctrine rests on the red-on-old pin.

### P47. The Mac's whole protection surface has no rendering pin; the ruled 13p disclosures are pinned as string constants only

`App/Variorum/VariorumTests/Phase13pCopySweepTests.swift:86`

**MINOR** · CONFIRMED · test-gap · lens: test-suite integrity · confidence 0.95

**Mechanism**

Grep over the entire test tree returns zero references to `ProtectionPane`, `StoreLockView`, and `MobileStoreLockView` (only `MobileProtectionSheet` appears, in `MobileTutorialWalkTests`). `Phase13pCopySweepTests.theOpenAppIsReadableLineStatesTheDecline` reads `ProtectionCopy.openAppIsReadable` and asserts its words, and its doc comment claims "the sentence is rendered where a mode is chosen" — but nothing pins the rendering. Delete `ProtectionPane.swift:277` (`Text(ProtectionCopy.openAppIsReadable)`) and the entire repo's tests still pass while the Mac ships its privacy pane without the R13p-16 non-goal disclosure. Identical shape for `ProtectionCopy.deadEnd(_:)`: lines 98-118 pin the per-demand lobby sentence (the acceptance walk's own catch — an impossible-cause line), but its only renderers are `StoreLockView.swift:126` and `MobileStoreLockView.swift:182`, neither hosted in a test, so removing that view from the locked lobby is silent. Not an infeasibility: the Mac suite hosts SwiftUI routinely (NSHostingView in BookOrderConversionTests.swift:330-345, BookViewTests, TakePaneDurabilityTests).

**Evidence**

> Phase13pCopySweepTests.swift:87 `let line = ProtectionCopy.openAppIsReadable`
> ProtectionPane.swift:277 `Text(ProtectionCopy.openAppIsReadable)`  — the only Mac renderer
> StoreLockView.swift:126 `Text(ProtectionCopy.deadEnd(lobby.demand))`
> `grep -rl ProtectionPane App/Variorum/VariorumTests App/Variorum/VariorumMobileTests` → no matches

**Why it matters**

That file's own header says this is "the one surface in the app whose whole claim is that it says what is actually so" and that "these pins fail the day such a mode appears" — but they fail only when the CONSTANT changes, never when the surface stops showing it. The failure mode is exactly the one R13p-16 refused: a screen that looks finished and says nothing.

**Verifier**

Verified by grep over both Mac and mobile test targets: zero references to `ProtectionPane`, `StoreLockView`, or `MobileStoreLockView` anywhere in App/Variorum/VariorumTests, App/Variorum/VariorumMobileTests, or Tests/. The only `MobileProtectionSheet` reference is MobileTutorialWalkTests.swift:1299, and it asserts the static `doorTitle` string appears in tutorial prose — not a rendering pin either. Phase13pCopySweepTests.swift:86-95 reads `ProtectionCopy.openAppIsReadable` and asserts its words while its doc comment claims 'the sentence is rendered where a mode is chosen'; the sole Mac renderer is ProtectionPane.swift:277, unhosted. Same shape for `ProtectionCopy.deadEnd(_:)` (Phase13pCopySweepTests.swift:104-121), whose only renderers are StoreLockView.swift:126 and MobileStoreLockView.swift:182 — the acceptance walk's own catch is pinned at the constant, not at the lobby. The infeasibility defence does not hold: the Mac suite hosts SwiftUI routinely (NSHostingView in BookViewTests, BookOrderConversionTests:332, BookHistoryPaneTests, BookAscentTests). This is a coverage absence rather than a live defect, which keeps it MINOR rather than MAJOR — but MINOR is right, not NIT, because 13p's own claim is that this surface says what is actually so, and the pins fail only when the constant changes, never when the surface stops showing it.

---

### P48. Five of six P1 benchmarks are gated by an absolute 2 ms floor, not the flatness ratio their names claim

`Tests/VariorumCoreTests/PerfBenchmarkTests.swift:57`

**MINOR** · CONFIRMED · test-gap · lens: test-suite integrity · confidence 0.92

**Mechanism**

`expectFlat` asserts `l <= max(s * factor, floor)` with `factor: 3.0, floor: .milliseconds(2)`. I ran `swift test --filter PerfBenchmarkTests` on this tree (2026-08-30, exit 0, 6/6 green) and read the medians the helper prints. In five of six pins `s * 3` is BELOW the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part: postRender s=0.655 (s*3=1.965), assembleReading s=0.584 (1.752), timelinePage s=0.618 (1.854), library s=0.310 (0.930), tagSubtree s=0.651 (1.953) — all under floor=2.000. Only `autosaveIsFlatInPostLength` (floor overridden to 1 ms, s=1.359 → 4.077) is ratio-bound. Concretely: `libraryPageIsFlatInCorpusTextSize:111` compares a 100x10 corpus with a 100x100 corpus (10x the text) and passes at ANY large-corpus timing up to 2.000 ms against a measured 0.310 ms — a 6.45x tolerated regression, i.e. a query whose cost grows as ~N^0.81 in corpus text ships green under a test named 'IsFlat'. This is the project's only automated P1 guarantee at the query layer and the baseline Phase 12 re-verifies against.

**Evidence**

> PerfBenchmarkTests.swift:49 `factor: Double = 3.0, floor: Duration = .milliseconds(2),`
> PerfBenchmarkTests.swift:57-59 `#expect(\n    l <= max(s * factor, Self.seconds(floor)),`
> Run log: `P1 library(limit 50), 100 posts at 1k vs 10k blocks — small: 0.310ms, big: 0.311ms`
> The project already ruled this class a defect on the phone — MobilePerfWalkTests.swift:531 `//   is the only binding bound is the record-claim class):` — and renamed the mobile pins accordingly; the core suite never got that treatment.

**Why it matters**

P1 is a hard constraint ("cost proportional to viewport, never corpus") and these six pins are the only thing that enforces it automatically. As written, five of them enforce "under 2 ms on this machine", not flatness, so a several-fold scaling regression on renderPost / assembleReading / timeline / library / tagSubtree lands with a green suite and a test name that asserts the opposite.

**Verifier**

Traced and re-measured. `expectFlat` (PerfBenchmarkTests.swift:48-61) asserts `l <= max(s * factor, floor)` with factor 3.0 / floor 2 ms. I ran `swift test --filter PerfBenchmarkTests` on this tree (6/6 green): renderPost s=0.639 (s*3=1.917), assembleReading s=0.579 (1.737), timelinePage s=0.574 (1.722), library s=0.320 (0.960) — all below the 2 ms floor, so the floor is the only binding term and the small-corpus median plays no part. One correction to the finding's arithmetic: tagSubtree measured s=0.703 on my run (s*3=2.109 > 2 ms), so it flips run-to-run — it is FOUR pins clearly floor-bound plus one marginal, not a stable five. autosave (floor overridden to 1 ms, s=1.343) is genuinely ratio-bound. The consequence stands: `libraryPageIsFlatInCorpusTextSize` tolerates any big-corpus median up to 2.000 ms against a measured 0.320 ms — a ~6x scaling regression passes under a name asserting flatness. Not refutable as a documented tradeoff: the suite docstring claims the opposite of what happens ('absolute timings are machine noise, ratios are the assertion'), and notes/plans/phase-04-read-layer.md:83 likewise reports these as ratio assertions. The project itself already ruled this exact class a defect on the phone — MobilePerfWalkTests.swift's bounds comment, verbatim, 'a pin named "flat" whose floor is the only binding bound is the record-claim class' — and renamed the mobile pins to say which term binds; the core suite never got that pass. Severity MINOR is right: no shipped behavior is wrong, but these six are the only automated P1 guard at the query layer and the baseline Phase 12 re-verifies against.

---

### P49. Nothing pins that a synced table actually has its outbox-capture triggers, so a future table can join the registry and silently never sync

`Sources/VariorumCore/Sync/SyncSchema.swift:8`

**MINOR** · CONFIRMED · test-gap · lens: persistence+migrations · confidence 0.90

**Mechanism**

SyncSchema.swift's header promises that a table added to the schema 'is added HERE or it silently never syncs (the introspection test in SyncSchemaTests fails the build instead)'. The test that exists, SyncSchemaTests.registryMatchesLiveSchemaExactly:14-33, compares the registry only against the set of sync_version-carrying tables — it never looks at triggers. I searched the whole test tree: `grep -rn "outbox_" Tests/` returns nothing and `grep -rn "type = 'trigger'" Tests/ Sources/` returns nothing; no test introspects sqlite_master for triggers. Concretely, a v1_15 migration that creates `CREATE TABLE foo (... sync_version INTEGER NOT NULL DEFAULT 0 ...)`, adds `SyncTable("foo", ...)` to the registry and "foo" to MigrationTests.expectedTables, but omits `try createOutboxCaptureTriggers(db, table: "foo", pk: "id")`, passes registryMatchesLiveSchemaExactly, everySyncedTableCarriesSyncVersionDefaultZero, everyColumnOfEverySyncedTableIsClassifiedExactlyOnce, mirrorDDLCoversEverySyncedColumn and allTablesExist. Every ordinary write to foo then fails to enqueue, so device A's rows never reach device B and no error is raised anywhere; AccountLifecycleTests:267-273 would not catch it either, because resyncReinitialize enqueues by explicit `INSERT OR REPLACE INTO sync_outbox ... SELECT` (SyncEngine.swift:408-413), not by trigger. The identical gap covers tombstone cascades: nothing asserts a new child table gained its cascade_* trigger.

**Evidence**

> SyncSchema.swift:6-9 — "if a table is added to the schema, it is added HERE or it silently never syncs (the introspection test in `SyncSchemaTests` fails the build instead)."  ||  SyncSchemaTests.swift:27-31 — `#expect(Set(SyncSchema.tables.map(\.name)) == synced, "registry drifted from the set of sync_version-carrying tables")` — `synced` is built purely from `columns.contains(where: { $0["name"] == "sync_version" })`.  ||  Triggers.swift:131-144 — createOutboxCaptureTriggers is called per table by hand (13 in createOutboxCapture's list, 6 more at v1_5/v1_7/v1_8/v1_10/v1_14), never driven off SyncSchema.tables.

**Why it matters**

The completeness-walk discipline this project already trusts elsewhere (SerializerCompletenessTests, AuthRLSDDLTests.everyDataTableIsRebornMultiTenant, both registry-driven) exists precisely because the postmortem-#4 serializer drift class is invisible at runtime. The trigger half of that class is the one with no guard, and its failure mode — a table whose writes never leave the device — is silent on both machines until data is noticed missing. Today's 19/19 coverage is correct; only the pin is absent.

**Verifier**

The gap is real. I grepped the whole test tree: the only sqlite_master introspections are for TABLES and INDEXES (SyncSchemaTests.swift:19, MigrationTests.swift:66/75/93/105, BlockCommentTests.swift:26/32, ReadingSectionTests.swift:42, BridgeStateTests.swift:76) — `type = 'trigger'` appears nowhere in Tests/, and `outbox_` (the trigger-name prefix minted at Triggers.swift:135) appears in no test. registryMatchesLiveSchemaExactly (SyncSchemaTests.swift:16-31) compares the registry only against the set of sync_version-carrying tables, exactly as the finding says. TriggerTests' outbox suite exercises three tables by hand (container, setting, and a block cascade) — never the registry, so a 20th registered table with no trigger pair passes every existing pin. Trigger creation is by hand-maintained list (Triggers.swift:107-125, 13 tables) plus six later per-migration calls (Migrations.swift:168, 256, 257, 299, 362, 465), never driven off SyncSchema.tables, so nothing structurally couples them. Two corrections to the finding's framing, neither fatal: (a) the SyncSchema header's promise is accurately about REGISTRY drift, which registryMatchesLiveSchemaExactly does enforce — the finding reads it as covering triggers, which it does not claim to; (b) today's correspondence is exact (19 registered tables, 19 trigger pairs), so this is a preventive pin, not a live defect. MINOR is the right rating — real, narrow, and future-facing, but the failure mode (a table whose writes never leave the device, silent on both machines) is precisely the class this codebase pins by introspection elsewhere.

---

### P50. The keyed-store WAL plaintext scan cannot fail — the WAL is checkpointed away before the test reads it

`Tests/VariorumCoreTests/KeyedStoreConvergenceTests.swift:87`

**NIT** · CONFIRMED · test-gap · lens: test-suite integrity · confidence 0.85

**Mechanism**

Lines 80-81 call `binding.lock()` on both stores, which runs `outgoing.close()` on the DatabasePool (StoreBinding.swift:97). Closing the last WAL-mode connection checkpoints and then deletes or truncates the `-wal`. Line 87 then reads that file with `try?`. Both outcomes are unfalsifiable: if the file is deleted, `try?` yields nil and the `#expect` at line 88 never executes; if it is truncated (the branch I reproduced on this machine — `sqlite3 t.sqlite "PRAGMA journal_mode=WAL; CREATE TABLE x(a); INSERT INTO x VALUES('prose');"` leaves a 0-byte `t.sqlite-wal`), `walBytes` is empty and `range(of:)` is trivially nil. So if SQLCipher ever wrote cleartext into the WAL during operation, this scan stays green, because it only ever looks after the checkpoint. Reading the `-wal` before `lock()` would be the falsifiable order. The store-file scan at line 84-85 is real and unaffected.

**Evidence**

> KeyedStoreConvergenceTests.swift:80 `a.db.asRebindable().binding.lock()`
> KeyedStoreConvergenceTests.swift:86-89 `let wal = URL(fileURLWithPath: url.path + "-wal")` / `if let walBytes = try? Data(contentsOf: wal) {` / `#expect(walBytes.range(of: Data(prose.utf8)) == nil,`
> StoreBinding.swift:97 `try outgoing.close()`

**Why it matters**

This test is the phase's named direct evidence for "convergence green over the encrypted store … byte-scanned" (its own header, R1-m6). Half of that byte scan — the journal, which is where in-flight page images live — is a branch that never runs, so the suite claims coverage of a leak path it never inspects.

**Verifier**

Mechanism verified. SyncTestHarness.swift:71 opens the client via `AppDatabase.openStore(at:custody:)`, i.e. `.direct` storage, so `a.db.asRebindable()` (AppDatabase.swift:69-76) mints a fresh StoreBinding over that same writer and `lock()` (StoreBinding.swift:88-102) calls `outgoing.close()` on the pool — the last connection. SQLite then checkpoints and deletes-or-truncates the `-wal`; I reproduced the truncate branch on this machine (sqlite3 WAL write, clean exit, `t.sqlite-wal` left at 0 bytes). KeyedStoreConvergenceTests.swift:86-89 reads that file only AFTER lock(), with `try?`, so either the file is gone (nil, the #expect never runs) or empty (`range(of:)` trivially nil). The scan is unfalsifiable as ordered. Two corrections that lower the stakes: (a) the store-file scan at :83-85 is real and unaffected, as the finding says; (b) contrary to 'the suite claims coverage of a leak path it never inspects', the WAL leak class IS inspected live elsewhere in the same target — StoreEncryptionTests.swift:99-103 scans the `-wal` while the pool is still OPEN, with frames present ('WAL pages encrypt too'). So this is a redundant dead belt beside a live pin, not an uncovered guarantee. Downgraded to NIT accordingly; the honest fix is one line of reordering (scan before lock()).

---

## Refuted and dropped (15)

Kept so a future sweep does not re-find them and spend the same time. Each was raised by a finder and
killed by a verifier that opened the code.

- **An archived block survives its note's deletion as an invisible live row, and the 30-day purge then orphans it permanently** *(lens: ops: lifecycle)* — Mechanically the chain is real and I traced every link: Triggers.swift:60-63 cascades block tombstones only through LIVE placements, so an archiveBlock'd block (whose placement is already tombstoned, Operations+BlockArchive.swift:76-84) survives deleteContainer; Trash.swift's block arm requires b.deleted_at IS NOT NULL, strandedOriginals requires b.archived_at IS NULL AND c.deleted_at IS NULL, archivedBlocks is note-scoped with its only production caller at TrayPanel.swift:364; PurgeFamily.expandContainer takes ALL container_block rows regardless of tombstone while memberBlocks requires b.deleted_at = c.deleted_at. BUT the finding is refuted on two grounds. (1) The cited mechanism for the last_container_id erasure is wrong: it is NOT the FK's ON DELETE SET NULL but an explicit, deliberate survivor-detachment UPDATE in PurgeFamily.deleteLocal (lines ~275-290), whose own doc comment names this exact case — 'a surviving block's last_container_id at a purged note' — done as an enqueued UPDATE precisely so the mirror converges. The code anticipates surviving blocks pointing at a purged note by design. (2) The end state is documented and disclosed, not silent: expandContainer's inline comment states 'an archived block is live and never rides'; notes/plans/phase-13j-deletion-and-trash.md's batch-6b record lists under 'Recorded consequences, none improvised': 'archived blocks of a purged note lose their last_container_id context (they were already faceless once the note DELETED — a pre-existing batch-6-era corner, noted for the walk, not widened here)'; and QUESTIONS #72(d) tells the author in her own list that 'Archived blocks and archived notes are UNTOUCHED by every purge road.' Also, the finding overstates permanence: while the note sits in the Trash the archived block is fully recoverable by Putting the note back (restoreContainer revives the container, last_container_id still points at it, the tray lists it again) — the unreachable window opens only after the note's purge. No row is destroyed, no invariant is violated, nothing is corrupted; this is a reachability corner already recorded and routed to the author's walk. Per the standing rule that a documented, acknowledged tradeoff is not a finding, REFUTED — with the note that severity, were it novel, would be MINOR (requires archive → whole-note delete → purge, prose rows intact throughout).

- **A preserved original detached by one note's purge is later physically deleted having appeared on zero recovery surfaces** *(lens: purge & trash)* — The two load-bearing claims are false in the real source. (1) "Listed on NO surface at all": the finding enumerates strandedOriginals / preservedOriginals / unplacedBlocks and misses the surface built for exactly this population — Queries.unplacedOrigins (Lineage.swift:104 and :151, the 13j J3 lineage door, absorbed into the Block History pane's came-from region plus the block right-click menu and ⌘K per OriginPeek.swift). Both variants select on `edge` + `NOT EXISTS(live placement)` with NO last_container_id predicate, so in the finding's own trace (successor B alive in note Q, edge B→X untouched because B is outside P's family) X remains visible and Put-back-able after P purges. A real cross-note door exists too (BlockTOCView.swift:252 moves a block to the pool), so the trace's step 2 is reachable — and it is precisely the case the lineage door serves. (2) "She was never shown a countdown for it, not once": Trash.originalsStrandedBy (Trash.swift:486) is lineage-only — no last_container_id — and is wired into the delete receipt via StrandedOriginals.note (TrayPanel.swift:614; mobile MobileStructural.swift:766), so the delete of the last live descendant names the stranded original exactly as her round-8b (d) requires. (3) Mis-attribution: block.last_container_id REFERENCES container(id) ON DELETE SET NULL (Migrations.swift:518), so the physical container delete NULLs the pointer with or without the detachment arm; the arm exists only so the change enqueues and pushes (PurgeFamily.swift:245-255). Changing it would fix nothing. Real residue, and only this: an original whose home note has already been PURGED can no longer list in the Trash's clock-bearing .preservedOriginal section (Trash.swift:332's INNER join demands a live home note), so the ruled "told twice" degrades to "told once (the receipt)". Narrow (needs a preserved original + a descendant surviving the home note's purge + the home note actually purged + the survivor later deleted), and the orphan class was explicitly weighed at design time (phase-13j-deletion-and-trash.md round 8b names "a live original whose note purged has NO honest surface"). Not MAJOR data-loss.

- **The iCloud-Keychain escrow copy is write-only — no shipped door reads it — while the settings pane, the loss-math and the runbook all name it as a way back into the library, and the dial is ON by default** *(lens: crypto & key custody)* — The code facts are accurate — `loadEscrow` has exactly one production caller (ProtectionController.swift:494, a consistency read inside the reconcile), and no open/lobby/failure road consults it — but this is a documented, owned deferral, which the rules classify as REFUTED. StoreKeyGuard.swift:20-23 states it outright: "The escrow item ... is NEVER an open road: the app never consults it at open — it exists for RECOVERY on a machine that signed into the same iCloud (13x's adoption door)." The 13p ladder adjudicated exactly this scope: the plan's VERIFICATION bullet was amended at R1-M3 (phase-13p-note-protection.md:647-654) to "the SAME-MACHINE legs are this phase's to prove ... the full NEW-MACHINE adoption drill — the escrow leg included — is 13x's, named as its inheritance on the master-plan row," and FuturePhases.md:28 carries that inheritance verbatim on the 13x row, which is PRE-LAUNCH in the running order (row 7, before the 🚀). The `escrowOn`/`lossLegs` wording is author-ruled knot-8 text, and 13s is scheduled to re-voice it. Two further corrections to the finding's framing: on the Mac the escrow item cannot even land today (the -34018 signing gap, its own KnownIssues row), and the pane says so explicitly at ProtectionPane.swift:299-306 — so "the raw store key is pushed into iCloud by default" is false on the platform under review. The residual worth carrying is only that the copy is present-tense ahead of 13x.

- **The sidecar recovery road is gated on `keyUnavailable` only, so a wrong-key open (a backup restored from a different library) is a dead end despite working wraps beside the store** *(lens: crypto & key custody)* — The two code facts are true (AppBootstrap.swift:278's `guard error.keyUnavailable`; AppDatabase+Dependency.swift:128 returns the held key unverified), but the scenario does not hold. The runbook recipe the finding cites as the road (notes/DataSafetyRunbook.md §3, read in full) says "Take only the `.sqlite` file" — the sidecar is deliberately NOT restored, and the store key never rotates, so a SAME-library restore (the only kind §3 describes) opens under the held key and never reaches this path. For the finding's actual scenario the user must restore a DIFFERENT library's `.sqlite`; then the sidecar beside the store is still the LOCAL one, whose wraps unwrap the LOCAL key — offering the envelope road would hand back a key that also fails to open the restored file, so the proposed remedy does not remedy it. Only if the user additionally hand-copies the foreign `variorum-keys.json` would the road help, and cross-library adoption is the explicitly deferred scope: the 13p ladder's R1-M3 adjudication (phase-13p-note-protection.md:2050-2057) scoped this phase to SAME-MACHINE legs and named the new-machine adoption door as 13x's, with FuturePhases.md:28 carrying it. A genuine residual remains — an unverified held key silently hides the envelope road — but it is narrow and its owner is named.

- **The reset door's "the old passphrase no longer unwraps anything" holds only for the sidecar beside the store — every backup folder keeps a copy of the old envelope, and the store key itself is never rotated** *(lens: crypto & key custody)* — This misreads a scoped doc comment as a global guarantee. StoreKeyEnvelope.swift:100-104 says the old wrap "is GONE, not shadowed" — a statement about THIS envelope's data shape (there is no second wrap row inside it that a stale descriptor could still satisfy), and that is exactly what `StoreKeyEnvelopeTests` pins. It makes no claim about copies of the file. I searched for a user-facing revocation promise and found none: `ProtectionCopy` carries no reset blurb asserting the old passphrase stops working, and R13p-9 (phase-13p-note-protection.md:130-136) frames the door as the "forgot-passphrase RESET door," which is the "I forgot it" reading the finding itself concedes is honest. Store-key rotation is nowhere claimed — the design is one key per store minted at migration/first launch (StoreKey.swift:8-13), and the loss math is written against key custody, not against secret revocation. Two factual corrections as well: `StoreBackup.copyKeyEnvelope` (:239-249) rewrites the destination whenever the bytes differ, so each backup folder's stale envelope is overwritten on the next run rather than kept "until" some indefinite future; and the in-container `Backups/` folder is refreshed on the same clock. What survives is a design observation about a design nobody claimed otherwise for — cosmetic at the doc-comment level.

- **The V3 duplicate-day trap is closed only at saveNoteVersion; duplicateAsVersion / promoteLens / promotePicks / divergePostForReading still copy entry_date onto a second live journal note and permanently pause that day's bridge push** *(lens: fragments bridge)* — The MECHANISM is real — I confirmed copyPost copies profile and entryDate verbatim (Operations+Versions.swift:590-593), that only mintNoteVersion nils it (Operations+NoteVersions.swift:77), that duplicateAsVersion/promoteLens/promotePicks/divergePostForReading do not, that duplicateAsVersion is reachable with no profile gate (LibraryCatalogView.swift:826), and that the push scan pauses any day with >1 live journal-profile container (BridgeEngine.swift:785-791). But the finding's load-bearing claim — "silently freezes that day's Fragments projection indefinitely" — is FALSE, and it is falsified by the very surface the finding never opened. report.pausedDays → status.pausedDays is rendered EVERY round, in orange, by BridgeStatusRow (App/Variorum/Shared/BridgeStatusViews.swift:69-79, mounted at RootView.swift:151), naming the day and the remedy verbatim: "· <day> paused (two entries — delete or re-date one to resume)". It is durable and recurring (recomputed by the scan each round) and is even PRESERVED across failed rounds by the scheduler's catch branch — the exact opposite of finding 1's one-shot tooltip. That difference is also precisely why V3 was a trap and this is not: the polish-round record (post-13l-polish-round.md:3909-3917) says the version case would go quiet "with no visible cause" because a version copy is born archived + sealed and never appears in the Library — the second row is INVISIBLE. A duplicateAsVersion/diverge copy is a live, visible note the author just minted by an explicit gesture, sitting in the Library beside the original, so the warning's instruction is directly executable. Further, the behavior is documented and owned at three levels: duplicateAsVersion's own doc states the container row is copied "title/profile/entry_date/notes/segmentation verbatim"; the duplicate-day pause is deliberately the SAFE choice over newest-wins (the code comment: "a slipped push would LWW-overwrite one text with the other on the Fragments side"); and it is author-ratified behavior (QUESTIONS #14, AppSpecDeltaArchive: "archiving does not release the duplicate-day pause — delete or re-date does"). The conflict-card consequence is likewise the ratified conflict-as-variant doctrine (nothing clobbered, S5). What remains is a legitimate taste question — should the sibling copy doors drop entry_date the way the mint does, so a duplicate never claims a day another note holds — but that is a design call with a visible, actionable, ratified fallback, not a silent invariant violation.

- **Lock Library Now closes the store without filing the home-screen quick note — an unminted capture dies with the suspended app** *(lens: mobile app)* — The finding's load-bearing inference — "the `.background` road proves the leg was missed rather than ruled out" — is contradicted by a comment in the very file it cites and never quotes. MobileRelock.swift:81-89 (directly above `mobileWillLock`): "The quick-note box is DELIBERATELY not minted here: its worded refusal — the text STAYS in the box and the sentence names the lock and the road — is Batch 4's ruled behavior for the re-lock seam (her item (i) ratification), and a silent mint here would replace that ruling." The ratification is in notes/plans/phase-13p-note-protection.md:1033 ("under the demanded modes, the home-screen quick note (and any capture surface) demands unlock before minting — an honest refusal, never a plaintext side-channel"), and VariorumMobileApp.swift:105-113 repeats the structural half. The refusal sentence exists and is tested (MobileQuickNoteCopy.refusal's StoreLockedError arm; MobileQuickNoteTests.swift:402-460 pins refused-mint-keeps-the-text + the one re-armed retry). The finding is also wrong that the bytes only live in a doomed view: the model hangs off `MobileShellRouter`, which is `@State private var shellRouter` on the App struct (VariorumMobileApp.swift:33), so it survives the `.ready`→`.locked` subtree teardown for the life of the process. The road additionally needs an opt-in demanded mode (`lock()` guards `dials.mode.isDemanded`) plus Lock Now inside the ~1 s mint window. Two adjacent gaps I did find and that this finding does NOT name, worth their own report: `mobileWillLock` drains only `editors.flushAll()`, never `session.flushEveryOpenPost()`, so a MINTED box's debounced tail is undrained at lock; and `MobileQuickNoteModel.bind` is `if self.session == nil` (line 276-278) while `beginOpening` mints a FRESH `AppSession` per open (AppBootstrap.swift:331), so after unlock the box holds a dead session and the ruled "unlock and it will save" recovery cannot fire. As written, the finding is a documented, ratified tradeoff.

- **ProtectionController's mode/escrow doors run up to four synchronous SecItem calls inline on the MainActor — the class 13e batch 9 and this file's own ladder R2-m2 both hopped off-main elsewhere** *(lens: concurrency & threading)* — The factual half is accurate — `currentKey()` (:120-122) calls `guardSeam.loadAuto()`, which is `{ custody.load() }` (StoreKeyGuard.swift:67) onto a synchronous `SecItemCopyMatching`, and `setMode` (:306-346), `setEscrow` (:352-390) and `generateAndLandRecoveryPhrase` (:258) do run those round-trips inline on the MainActor. But it does not hold as a defect. (1) NO INVARIANT IS TOUCHED: it is filed perf-p1, and P1 is cost ∝ viewport+edit while P2 is DB I/O off-main; Keychain IPC is neither, and no rule in CLAUDE.md, AppSpec §4-5, or OverallModel §5 covers it. (2) THE PRECEDENTS ARE THE WRONG CLASS, and the code says so itself: R2-m2's own comment at :455-461 scopes its hop to 'this launch/unlock cadence' — an AUTOMATIC arm running before the user has done anything — and 13e batch 9's fix (EncryptionKeychain.swift:121-151) was for a synchronous load at APP CONSTRUCTION, captured as the windowless-launch cluster in KnownIssues. Both were roads with captured evidence where the user was not the one who asked. These are one-shot, deliberate Settings taps with a `busy` spinner already rendered (ProtectionPane.swift:123, 480), which is ordinary AppKit practice. (3) NO CONSEQUENCE IS DEMONSTRATED on these roads — the beachball is conditional on a stalled securityd, and the KnownIssues windowless-launch row records that the captured stall's CAUSE was fixed and the surviving residue has a different mechanism (main thread idle in `__CFRunLoopServiceMachPort`, no securityd frame). The finding's own strongest sentence — 'an inconsistency that will read as intentional to the next reader' — is the honest description: this is a consistency observation, not a traced defect.

- **~7,500 lines of below-the-UI logic live in the app target's Shared/ instead of VariorumCore, so `swift test` cannot reach the data-safety or key-custody code** *(lens: architecture conformance)* — The measurements are roughly right (30 of 39 Shared/ files import no UI framework; the total is ~8.4k lines, not 7.5k) and Package.swift does cover only Sources/VariorumCore. But the premise is refuted by canon: notes/MobileSoul.md:55 states outright that 'Brains live in `VariorumCore` (or `App/Variorum/Shared/`)', and KnownIssuesAndTechDebt.md's forked-brain row prescribes hoists into `Shared/` ('or core Domain where pure') as THE fix. App/Variorum/Shared/ is an explicitly sanctioned home, not a violation of AppSpec §2. The verification claim is also wrong in substance: this code is heavily pinned in the app targets — DataSafetyTests, Phase13pSubstrateTests, Phase13pKeyedDrillTests, Phase13pLobbyTests, Phase13pControllerTests, EncryptionFlowTests, KeychainOffMainTests, MobileProtectionTests all reference StoreBackup/StoreProtection/StoreLaunchGate/MarkdownInsurance — and `xcodebuild test` is a first-class documented command in CLAUDE.md whose counts every closeout reports (13p: Mac 1843/312). Most of the named files are genuinely app-shaped anyway (@MainActor, AppSession/AppBootstrap/AuthSession lifecycle, Keychain reached through app-target signing identity). What survives is a NIT-sized kernel: a couple of genuinely pure rules (BackupRetention, 136 lines of Foundation-only pure function) would sit as naturally in VariorumCore/Domain.

- **The read-cheap tier re-implements the projection-application decision outside EditorProjectionPolicy, the shared brain four other surfaces share** *(lens: architecture conformance)* — The code facts hold: ReadPostViewModel.swift:191-203 carries its own two-outcome if-chain and does not call EditorProjectionPolicy.decide (grep confirms the callers are EditorViewModel.swift:638, TakesViewModel.swift:351, MobileEditorViewModel.swift:573). But it is documented and deliberate, and the differing cases are structurally inapplicable rather than drifted. The file's own header (ReadPostViewModel.swift:14-21) states the read tier's update discipline as a decision: 'projections apply DIFFERENTIALLY when the block sequence is unchanged … The surface is never edited by the user (non-editable), so the last adopted projection IS the surface text — comparisons are in-memory, zero surface reads.' Every policy case the read tier omits — deferUntilClean, adoptEcho, forcedFullRender, refetchFresh — exists to protect a dirty local buffer or a stale delivery over one; a non-editable surface has no local edits to lose, so a stale delivery costs at most one frame of old text until the next observation. The finding itself concedes 'the reduced decision may be correct for this surface today' and that there is no present miscomputation. The cited MAJOR-C precedent is a different mechanism (a decor-sink wiring gate, ReadPostViewModel.swift:169-179), not a projection-policy drift. What remains is a maintainability preference with no traced consequence.

- **Three quick-capture doors, two behaviours: phone quick notes never reach the Quicknotes book the Mac pad populates, and the divergence has no owner** *(lens: architecture conformance)* — The three code sites are exactly as quoted (QuickNoteView.swift:242-244 mints + fileAsQuicknote in one runner turn; QuickEntryBar.swift:82-85 and MobileQuickNote.swift:661-665 call importPost alone; fileAsQuicknote appears nowhere under VariorumMobile). But the finding's NEW claim — the owner gap — is false, and the divergence is a deliberate ruled-for-the-build decision awaiting the author. notes/plans/mobile-round-2.md §11 says it in terms: 'HELD FOR HER (not ruled autonomously) — F2, where a quick note lands. Ruled for the build: bookless … But the Mac's two capture surfaces genuinely disagree (its floating pad files into Quicknotes via fileAsQuicknote, her own R6-4 ruling there) … It is REVERSIBLE in one call, so the build proceeds bookless and the question rides the next sitting's bundle.' It was then folded into the handoff's OPEN WITH HER list — mobile-round-2-orchestrator-handoff.md:363-368, item 6, verbatim — and the master plan's running order row 11 names that handoff as the document mobile resumes from. So it has a named home and a valid owner (the mobile project row, which KnownIssues' own R2-7 clause explicitly accepts as an owner). KnownIssues' rule governs entries in that file; it does not require every author-pending taste call to have a row there. Note too that the Mac's own two doors disagree, which the record calls out — so this is not a platform-parity defect. Not a finding: an author decision in flight, already carried.

- **EditorViewModel is a 3,104-line god object with 136 functions, 85 stored properties and 30 responsibility bands; its 13b extraction was begun and stopped** *(lens: architecture conformance)* — The measurements check out (3,104 lines, 135 `func` declarations, 30 MARK bands, one construction site at EditorView.swift:49). But the finding's only consequence argument — 'the extraction was begun and stopped', leaving applyDifferential and the applyProjection if-chain behind as the substance of findings 1 and 4 — is factually wrong on both halves. (1) EditorViewModel DOES consult the shared brain: EditorViewModel.swift:638 is `let decision = EditorProjectionPolicy.decide(...)` and :649-682 is a switch over the seven cases; the if-chain was retired here, not left behind. (2) applyDifferential is NOT in this file — 13b Stage 3 moved it to EditorSurfaceController, and the class header (lines 20-24) records that boundary as deliberate: 'the gesture-execution band and the projection executors live in EditorSurfaceController; this class remains the STORAGE OWNER … and forwards the band's surface so every call site and pin reads unchanged.' The triplication in finding 1 is across three different surfaces on two platforms and has nothing to do with this file's line count. So two documented extraction passes landed (Stage 1a to Shared/EditorBrain, Stage 3 to EditorSurfaceController), not one that stalled. What survives is a bare size measurement against CLAUDE.md's hygiene guidance with no traced consequence — and the finding itself certifies P3 is not violated by it.

- **AppSettingsView's three settings observations are empty catches, and the setters then guard against the stale displayed value** *(lens: silent failures)* — The quoted code is accurate (three `} catch {}` at :257/:268/:278, hard-default seeds at :94/:98/:101, and setters guarding on the displayed value at :286/:306/:317) — but the consequence chain does not occur. (1) `Queries.defaultSegmentation` (AppearanceQueries.swift:62-66) cannot throw on data: an unknown/missing value falls back to `.paragraph`, so the stream only errors on a genuine DB failure (closed/locked pool) or cancellation — and `for try await` throwing CancellationError on teardown is precisely a legitimate reason for the empty catch. (2) The Settings scene is gated on `.ready` (VariorumApp.swift:239-248), so a lock or a store failure swaps the whole pane for a placeholder and the observation task dies with it; there is no state in which the pane is displayed over a broken store long enough to lie. (3) The named harm — "selecting `paragraph` writes nothing" — needs the user to select the already-displayed item, which a SwiftUI Picker does not deliver to the binding's setter at all; the guard is the standard no-op-write idiom used by every setter in the file. Style-level at best.

- **The key-envelope copy into a backup folder fails silently while the run still records "everything worked"** *(lens: silent failures)* — The reading is textually right — copyKeyEnvelope (StoreBackup.swift:238-249) is `try?`/`try?`, returns Void, is called outside both legs (:214, :297-300), and BackupLog's `everythingWorked` (:85-89) has no term for it — but two things refute it as a finding. (1) The quietness is deliberate and documented AT THE SITE: "Quiet on failure like every leg-side write — the next run retries; the snapshots themselves never depend on it" — the same contract as writeRunbook beside it, which is the project's documented-accepted-consequence class. (2) The realistic destination failures the finding names are all caught by legs that DO record: a revoked/stale security-scoped bookmark makes `BackupDestination.resolve` return nil → `leg.outcome = .failed` with a worded detail (:281-286); a read-only or full volume throws out of `createDirectory`/the snapshot copy inside `withAccess` → the same failed leg; a container-side failure fails the primary snapshot, which is recorded with its own integrity line. The only residue is a file-specific write failure at the destination (e.g. a pre-existing, differently-owned variorum-keys.json) while its sibling snapshot in the same folder succeeds — narrow enough that the documented retry-next-run rationale covers it. No confirmed road where the record says everything worked and the recovery legs are genuinely missing.

- **The two-tenant zero-plaintext pin has no coverage guard, unlike its 14b sibling in the same repo** *(lens: test-suite integrity)* — The quoted code is accurate (MultiTenantSyncTests.swift:170-179 has no `coveredColumns` accumulation; SyncMirrorDumpAndResyncTests.swift:85-112 does) but the inference does not hold. That test's fixture is deliberately narrow — makeWorld() plus four `createPost`/`createOrOpenJournalEntry`+`newBlock` calls (lines 60-125) — so it never populates most encrypted columns by construction, and the sibling's `coveredColumns == everyEncryptedColumn` guard would be unmeetable here, not merely absent. The pin's stated claim, in its own comment, is the TENANT axis: 'every encrypted-classified value stored server-side is ciphertext … for every account alike' — which is exactly what the nest asserts, over a fixture whose container.title and variant.working_text do reach the server as `.text`, so the #expect is not vacuous today. The regression class the finding worries about (an encrypted column stored as `.blob`, or a fixture that stops populating one) is caught corpus-wide by the sibling's coverage guard, as the finding itself concedes. A style/drift observation about two pins of different claims, with no traced consequence.

## Coverage and its honest limits

Raw findings per lens before verification:

| Lens | Raw |
|---|---|
| persistence+migrations | 3 |
| ops: lifecycle | 2 |
| ops: structural core | 2 |
| undo/redo | 5 |
| sync engine | 2 |
| purge & trash | 2 |
| crypto & key custody | 6 |
| fragments bridge | 2 |
| read layer & P1 | 4 |
| pure domain functions | 3 |
| shared editor brain | 2 |
| Mac editor feature | 5 |
| Mac takes/compare/canvas | 3 |
| mobile app | 5 |
| concurrency & threading | 4 |
| architecture conformance | 6 |
| silent failures | 5 |
| test-suite integrity | 4 |

**What this sweep did NOT do**, stated so the coverage is not overread:

- It **ran no code**. Nothing here is a measured runtime number unless the finding quotes one that
  already existed in the repo. The P1 findings are traced-by-reading, not benchmarked; the two
  already-measured twins in KnownIssues are the calibration for believing them.
- It **wrote no red-on-old pins**. Under this project's own hallucination guard, a bug-class finding
  is not fixed until whoever fixes it has traced the mechanism themselves and lands a test that fails
  on the pre-fix code. Every finding here has the traced mechanism; none has the pin.
- It read the tree as of this date on `main`. Findings in `Sources/VariorumCore/Sync/` are subject to
  the standing Fable rider regardless of which phase takes them.
- Verification was one adversarial pass per finding, not a panel. The single PLAUSIBLE finding (P8)
  is flagged as such because the verifier judged it needed a run to settle, not a read.

## Audit — every finding tempered, checked, and homed

Built 2026-08-30 at the author's instruction: *"ensure all finder's findings have been tempered by
verifiers and that what is in all of the plan files / documentation are correct… to ensure that
everything has a home."*

**What the audit found and fixed.** Every one of the 65 raw findings reached a verifier and
received a verdict — **zero UNVERIFIED**, 15 refuted, 50 survived. But a real gap existed in the
plan files: their entries were generated from the **finder's** mechanism text, while the verifier's
corrections lived only in this document. **31 of the 50 verifier notes contain material
tempering** — a refuted limb, a corrected number, a downgraded severity, an "already documented"
— so a fresh session reading a plan file would have acted on the finder's unchecked claim. P39 was
that failure mode caught by hand (its "20 mutual pairs" measured as 8).

**The fix, applied to all 50:** every entry in `phase-17-standing-fixes.md` and in the 13u1 fold
now carries the verifier's full trace inline, under an explicit precedence line — *where the two
differ, the verifier wins, because it was written with the real code open and instructions to
refute.* Severities in the plan files were already the verifier's corrected values, not the
finder's.

| P | Finder → Verifier severity | Verdict | Verifier tempered it | In plan, with temper | Home |
|---|---|---|---|---|---|
| P1 | MAJOR | CONFIRMED | **yes** | ✓ | 17a |
| P2 | MAJOR | CONFIRMED | **yes** | ✓ | 17a |
| P3 | MAJOR | CONFIRMED | no — confirmed as written | ✓ | 17a |
| P4 | MAJOR | CONFIRMED | **yes** | ✓ | 17b |
| P5 | MAJOR | CONFIRMED | **yes** | ✓ | 17b |
| P6 | MAJOR | CONFIRMED | **yes** | ✓ | 17b |
| P7 | MAJOR | CONFIRMED | no — confirmed as written | ✓ | 17b |
| P8 | MAJOR | PLAUSIBLE | **yes** | ✓ | 17d |
| P9 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17d |
| P10 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17a |
| P11 | MINOR | CONFIRMED | **yes** | ✓ | 17a |
| P12 | MINOR | CONFIRMED | **yes** | ✓ | 17a |
| P13 | MINOR | CONFIRMED | **yes** | ✓ | 17a |
| P14 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17b |
| P15 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17a |
| P16 | MAJOR | CONFIRMED | **yes** | ✓ | 13u1 |
| P17 | MINOR | CONFIRMED | **yes** | ✓ | 13u1 |
| P18 | MAJOR | CONFIRMED | no — confirmed as written | ✓ | 17c |
| P19 | MAJOR | CONFIRMED | **yes** | ✓ | 17c |
| P20 | MINOR | CONFIRMED | **yes** | ✓ | 17c |
| P21 | MINOR | CONFIRMED | **yes** | ✓ | 17c |
| P22 | MINOR | CONFIRMED | **yes** | ✓ | 13u1 |
| P23 | MAJOR | CONFIRMED | **yes** | ✓ | 17e |
| P24 | MAJOR | CONFIRMED | no — confirmed as written | ✓ | 13u1 |
| P25 | MAJOR | CONFIRMED | no — confirmed as written | ✓ | 13u1 |
| P26 | MAJOR | CONFIRMED | **yes** | ✓ | 17e |
| P27 | MINOR | CONFIRMED | **yes** | ✓ | 17e |
| P28 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17d |
| P29 | MINOR | CONFIRMED | **yes** | ✓ | 17e |
| P30 | MINOR | CONFIRMED | **yes** | ✓ | 17d |
| P31 | MINOR | CONFIRMED | **yes** | ✓ | 17d |
| P32 | MINOR | CONFIRMED | **yes** | ✓ | 17e |
| P33 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17e |
| P34 | NIT | CONFIRMED | **yes** | ✓ | 17e |
| P35 | NIT | CONFIRMED | **yes** | ✓ | 17e |
| P36 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17b |
| P37 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17e |
| P38 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17e |
| P39 | MINOR | CONFIRMED | **yes** | ✓ | *undecided — options recorded* |
| P40 | MINOR | CONFIRMED | **yes** | ✓ | 13u1 |
| P41 | MINOR | CONFIRMED | **yes** | ✓ | 13u1 |
| P42 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17f |
| P43 | MINOR | CONFIRMED | **yes** | ✓ | 17f |
| P44 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17f |
| P45 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17f |
| P46 | NIT | CONFIRMED | no — confirmed as written | ✓ | 17f |
| P47 | MINOR | CONFIRMED | no — confirmed as written | ✓ | 17f |
| P48 | MINOR | CONFIRMED | **yes** | ✓ | 17f |
| P49 | MINOR | CONFIRMED | **yes** | ✓ | 17f |
| P50 | NIT | CONFIRMED | **yes** | ✓ | 17f |

**Totals:** 50 findings · 31 materially tempered by their verifier · 50/50 present in a plan file
with the verifier's trace attached · 49 homed to a named entry, 1 (P39) recorded with options and
awaiting the author's call. **No finding is represented anywhere by the finder alone.**

*Severity shown is the VERIFIER's corrected value — which is what the plan files use. Where a
verifier downgraded (P17, P40) or refuted a limb of a multi-part finding (P5, P16, P32, P39, P48),
the plan entry now shows both the claim and the correction.*

## Dispositions — ASSIGNED 2026-08-30

Every finding has an owner. Assigned by the author the same day this sweep ran, so the KnownIssues
rule ("no item without a named owner") is satisfied without this file having to act as a tracker.

**This document is a dated snapshot and is NOT a tracking surface.** It is never edited to reflect
progress. The live state lives in the owning plan files and in `KnownIssuesAndTechDebt.md`.

| Owner | Items | P-numbers |
|---|---|---|
| **17a** | 8 | P1, P2, P3, P10, P11, P12, P13, P15 |
| **17b** | 6 | P4, P5, P6, P7, P14, P36 |
| **17c** | 4 | P18, P19, P20, P21 |
| **17d** | 5 | P8, P9, P28, P30, P31 |
| **17e** | 10 | P23, P26, P27, P29, P32, P33, P34, P35, P37, P38 |
| **17f** | 9 | P42, P43, P44, P45, P46, P47, P48, P49, P50 |
| **13u1** (folded into its plan file) | 7 | P16, P17, P22, P24, P25, P40, P41 |
| **unslotted — needs her call** | 1 | P39 |

**Where each owner's record lives:**

- **17a–17f** → `notes/plans/phase-17-standing-fixes.md`, the standing-fix phase opened by the author
  on 2026-08-30. Entries are independently scoped, cast, run and closed; the phase never closes. **17a
  is the urgent one** — the 13p residue, live on the real encrypted store, no user action needed to
  fire.
- **13u1** → the fold section at the end of `notes/plans/phase-13u-feel-and-polish.md`. Routed there
  and not to Phase 17 because 13u1's item 5 rewrites that exact seam; fixing them elsewhere means
  fixing them twice. Deliberately NOT added to the master plan's `### 13u` section, which stays
  product advancement only.
- **P39** → unslotted, and named as such in the Phase 17 file rather than smuggled into an entry.
  Architectural surgery (20 feature-to-feature pairs, a `Library`↔`Pool` view-model cycle) does not
  belong in a standing *quick fix* phase — that would misrepresent its size, which is the same
  pollution this arrangement exists to prevent, in the other direction. Three honest options are
  recorded there; leaving it unowned is the one bad one.

**Nothing here was fixed.** Every item carries a traced mechanism and a file:line and nothing more —
**no red-on-old pin exists for any of the 50.** Under the hallucination guard, step zero for each is
the pin that fails on the pre-fix tree, and a pin that passes on both sides dismisses the item as
hollow rather than fixing it.
