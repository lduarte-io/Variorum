# Independent design notes (written BEFORE reading the previous agent's proposal or cold read)

Written 2026-10-13 from: the 17 tickets + comments, QUESTIONS #216, pre-13x-postures-design.md §1–§7 + §14,
the VX-191 audit record, and the code: StoreLaunchGate (effectiveGate), StoreProtection (Posture.derive),
StoreKeyGuard, StoreKeyEnvelope (locate/loadCurrent), ProtectionController (reconcile, reconcileFollow,
sweepLingeringSilentItem, reconcileAppleKey), LibraryOpenModel.landCustody, AppBootstrap.routeAndOpen,
PostureSwitch writeMarker/clearMarker, RotationMarker, OwnerIdentity install, StorePlaintextExport.

## My diagnosis (what is actually wrong)

1. Mode is INFERRED, not RECORDED. Posture.derive reads five inputs: vault word, "enrolled" (= sync custody
   presence), the 13p legacy mode, the key file's `apple`/`passphrase` fields, and the custody SHAPE (which Keychain
   slot holds the raw key — corner 45). Several of those inputs are themselves written as side effects of reads.
2. Device custody is keyed by LIBRARY IDENTITY (storeID), but many COPIES with different keys and different
   modes share one storeID. Opening any copy overwrites "this Mac's custody for the library" — and because custody
   SHAPE is one of the mode inputs, opening an old copy changes the mode of the library. That is VX-209 exactly.
3. Readers write. `effectiveGate` lands an Apple copy; `landCustody` calls it; reconcile lands Apple copies,
   sweeps items, silently follows into Standard, re-lands silent items (the R1-M3 save). A misreading during any
   transient (mid-switch, mid-adoption, a closed lid, a slow vault read) becomes permanent state.
4. Copies are frozen with their day's wrappers, and nothing ever gives an old key a NEW route. A route that dies
   (A in an exposed state never landed; the passphrase did not exist yet) strands the copy (W-1 / VX-263), and the
   only rescue is a leftover file that another ticket (VX-213) wants to delete.
5. "Which key file is current" is a modification-time guess when several fingerprint files sit beside a store.
6. Long acts journal into the LIBRARY FILE (RotationMarker rows) plus side flags in UserDefaults keyed by storeID
   (switchPending, thisDeviceOnly). The library file is re-keyed, swapped and copied mid-life, so markers are lost
   (VX-235, VX-107) or outlive their act (the R1-1 flag-without-marker class) or ride into backups.
7. Account binding is implicit: "enrolled" = sync custody present (kept forever by Sign Out), the owner = rows'
   owner_id (stamped from WHOEVER is signed in, per call), and "posture is the account's" — so signing into a
   different account can re-stamp rows and flip modes. Session state and library binding are conflated.
8. Integrity: the route decides from the plaintext key file. A file-editing attacker (the login-password holder,
   squarely in Castle's threat model) can change the fields Posture.derive reads (e.g. drop the passphrase wrap ⇒
   `localReading` says Standard). I have not proven a full silent downgrade end to end, but the design gives the
   attacker the steering wheel; nothing pre-unlock is authenticated.

## My design (first principles)

Separate four things: LINEAGE (storeID — the library over time), KEY EPOCH (which key the lineage is under now),
MODE (Castle/Standard — a deliberate choice), and DEVICE CUSTODY (where this device holds the current key — a
CONSEQUENCE of mode + gate style, never an input).

1. Record, don't infer. Each lineage has a protection record: {lineage id, epoch n, current key fingerprint, mode,
   bound account or none, gate style}. Written ONLY by deliberate acts (enter/leave Castle, follow, Replace All
   Keys, setup/enroll/connect/disconnect, Always ask). Read by everyone else.
   - Device high-water mark: a per-device, per-lineage record in the Keychain (ThisDeviceOnly, non-synced) —
     tamper-resistant against other processes, not copied with the library, survives replacing the file.
   - Portable record: the same fields in the key file (a pre-unlock HINT only) and inside the library file
     (authenticated by SQLCipher; travels with every copy; read after unlock).
2. Never lower by opening. Opening/restoring a copy of the SAME lineage brings it under this device's CURRENT key
   and mode whenever that key is in hand (it is, whenever the app is running the library) — re-key the copy into
   the current key; the key file stays the current one. Mode after opening = max(device record, copy record). Only
   Leave Castle (deliberate, consented, re-authenticated) lowers. A DIFFERENT lineage keeps its own mode and the
   confirm line says concretely what will happen.
3. Key history travels forward. The live key file (ONE per lineage, no mtime guessing) carries every earlier key
   of the lineage wrapped under the CURRENT key (backward-only chain: new opens old, never the reverse). Every
   snapshot's key file is a frozen copy of it (decision 11 kept: never rewritten). So an old copy opens through its
   own day's wrappers OR through any newer key file of the lineage — and on the same Mac with the library open,
   with nothing typed. W-1 dissolves; VX-213's retirement of the leftover file becomes safe; the restore list has
   one rule.
   - Tradeoff to rule: after LEAVING Castle, the Apple copy of the current key also reaches keys retired DURING
     Castle (Castle-era backups under retired keys). Option h1 (simple): say so — "leaving Castle gives your Apple
     account a key to your library and the copies Variorum keeps of it". Option h2: a separate history key under
     P/W only (plus the Touch ID item while in Castle). I lean h1 unless she wants Castle-era copies to stay sealed
     after leaving.
4. Custody per KEY, not per lineage. Keychain items named by storeID + key fingerprint; the device record names
   the current fingerprint. Stray items for other fingerprints are inert and swept by the executor only.
5. One pure assessment, one executor. `assess(facts) -> verdict` is pure and is the ONLY decision code; every
   entry point (route, lobby unlock, ready, Open Library, Restore, the switches, follow, sign-in/out events) calls
   it. The verdict lists the acts owed and which need consent; ONE executor performs acts. Readers never write.
6. Acts are journaled OUTSIDE the library file. A per-lineage journal (Keychain item, or a sidecar MAC'd under the
   current key) holds the full plan and every fact a resume needs (old/new fingerprints, the NEW key wrapped under
   the old one before the swap, new corpus key id, byAnotherDevice, whether words were supplied). Each step is
   idempotent. Open Library refuses (or first finishes) while a journal is open. Backups never carry a journal.
7. Explicit account binding. The lineage record names its account. Binding changes ONLY by deliberate acts
   (setup, enroll/connect, disconnect / This-Mac-only / delete account). The auth session is separate: signed out
   ⇒ sync paused, mode = last-known account mode (never "indeterminate ⇒ act on custody shape"); signed in as
   another account ⇒ "this library belongs to another account — connect it?" Rows are stamped with the BOUND
   account, never whoever is signed in.
8. Proof by a generative model test: random sequences of user acts (open/restore copies of every era, enter/leave
   Castle, Replace All Keys, sign in/out/other account, delete account, add a finger, lid closed, iCloud Keychain
   off/on, Apple ID change, Time Machine container rollback, new Mac, crash at every step) against fakes, with
   invariants: Castle ⇒ nothing Apple-reachable opens the current key; the app never says Castle when that fails;
   opening a copy never lowers the mode; every copy Variorum made stays openable by some route the user still
   has; no read writes; crash+resume ≡ no crash.

## Things already built that hamstring the elegant answer (to tell her)
- Custody keyed by storeID alone (decision 13 / §1.13) — shared by every copy.
- "Posture is DERIVED, never a setting" (§3.1) — the central principle to reverse: record it, enforce custody.
- Several fingerprint-named key files beside a store, current = newest mtime (§3.5).
- Markers inside the library file + per-storeID UserDefaults flags (§4's AccountRekeyMarker pattern).
- "Enrolled" = sync custody presence; Sign Out keeps custody forever; owner_id stamped from the session.
- The pre-unlock route trusts a plaintext, unauthenticated key file.
- The 13p legacy read-through still inside the derivation.
- Decision 11 itself is NOT the problem — keep it; add the forward-travelling history.

## Product decisions I would put to her
D1 never-lower-by-opening (and the different-lineage rule) · D2 history under current key (h1) vs P/W-only key
(h2) · D3 explicit account binding + rows stamped by binding · D4 a restored copy is re-keyed into the current key
(cost: one export per restore of an older epoch) · D5 the offer: keep/delete (+ optional "re-protect older copies"
as a later feature) · D6 VX-212: quarantine undecryptable rows and let the rotation finish — never delete server
rows · D7 Touch ID after a biometry change asks before re-arming · D8 migration asks the passphrase once to fold
old keys into the history.
