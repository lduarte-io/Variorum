# App Strings workbook mint — the batch record (branch `tools/strings-workbook`, NEVER merges to main)

> **Not done in this batch (first line, per contract):** the MINT into her real store is HERS, never this
> session's — nothing here opens, reads or writes `~/Library/Containers/io.lduarte.Variorum/…`. No app build
> was installed; `/Applications` untouched. Road B (the one-off app door) was NOT built — Road A is viable
> (below), so the fallback stays unbuilt and its shared code path is ready if it is ever needed.

GitHub issue #5 (lduarte-io/Variorum) — the throwaway author-only generator that mints an "App Strings"
workbook book into her own store so she can rewrite the Mac app's user-facing copy inside her own app
(the 13s onboarding intake's copy-pass paragraph: `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`).
Branch rule (issue #7): this branch never merges; it lives for the mint and dies after.

## LIVE STATUS

| Piece | State |
|---|---|
| P0 — road decision + this record | DONE (this commit) |
| P1 — Package.swift targets (library `StringsWorkbook`, exec `strings-workbook-mint`, tests `StringsWorkbookTests`) | NOT-STARTED |
| P2 — the parser (`StringsInventory`) + Swift-escape renderer + the ⏎ correction table | NOT-STARTED |
| P3 — the tier plan (`TierPlan`) + the pure workbook plan (`WorkbookPlan`) | NOT-STARTED |
| P4 — the ops-driven mint (`WorkbookMint`) + the one-shot guard + read-back verification | NOT-STARTED |
| P5 — the headless unlock road (`StoreUnlock`) + the CLI | NOT-STARTED |
| P6 — tests green (`swift build`, `swift test --filter StringsWorkbookTests`) | NOT-STARTED |
| P7 — the end-to-end rehearsal: the CLI against a scratch ENCRYPTED store laid out like hers | NOT-STARTED |

## The road decision — ROAD A (headless executable), viable

**The custody fact that decided it.** The passphrase road needs no Keychain and no access group:

- `StoreKeyEnvelope.loadCurrent(besideStore:)` — `Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:501`
  — reads the key file (`variorum-keys-<fp16>.json`) BESIDE the store: a plain JSON file of non-secret
  wraps and KDF parameters (the file's own header, `:12`–`:21`: "deliberately not the Keychain … Holding
  the file grants nothing without the passphrase or the twelve words").
- `StoreKeyEnvelope.unwrapKey(passphrase:)` — `StoreKeyEnvelope.swift:356` — Argon2id (`PassphraseKDF`,
  the vendored PHC implementation; NFKD normalization inside `deriveKey`, `PassphraseKDF.swift:165`) +
  RFC 3394 `AES.KeyWrap.unwrap`. Pure computation; a wrong passphrase refuses (`wrongPassphrase`).
  The twelve words have the twin road, `unwrapKey(recoveryWords:)` — `:391`.
- `AppDatabase.openStore(at:custody:)` — `Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:88`
  — takes ANY `StoreKeyCustody`; `StoreKeyCustody.inMemory(initial:)` — `StoreKey.swift:170`. This is
  exactly the app's own LOBBY road: `AppBootstrap.swift:392` passes `StoreKeyCustody.inMemory(initial:)`
  for the key the lobby unwrapped, and `openStoreOffMain` (`AppBootstrap.swift:824`) documents "custody
  non-nil is the LOBBY's road … the device-Keychain custody is deliberately NOT consulted on that road".

The Keychain-gated items (the Auto/Biometric store-key items, `StoreKeyKeychain`, `StoreKey.swift:261`)
are the app's SILENT roads; the headless tool takes the typed-secret road instead, the same one the locked
lobby offers.

**Contingency (checked at run time, without any secret):** the road exists only if her key file carries a
LOCAL passphrase wrap (or a recovery wrap). `StoreKeyEnvelope.passphrase`/`.recovery` are optional — a wrap
lands only when a passphrase / the words were set on this library (`StoreKeyEnvelope.swift:64`–`:70`). The
lobby can ALSO unlock through the account vault over the network (the master-wrapped copy); the tool does
not take that road. The CLI says which local roads exist before prompting; if neither does, Road A is dead
for her store and Road B (the app door) is the fallback.

**Two facts outside custody that the road had to respect:**
- `owner_id`: the headless process runs signed out (`OwnerIdentity.liveValue = .signedOut`,
  `OwnerIdentity.swift:35`), so minted rows are born unowned; the app's `runOwnerAdoption` stamps them "at
  sign-in and at every signed-in launch" (`App/Variorum/Shared/AppServices.swift:435`–`:447`) before sync
  pushes — the same road every pre-sign-in row takes.
- The Release app is SANDBOXED; her store lives in `~/Library/Containers/io.lduarte.Variorum/Data/Library/
  Application Support/Variorum/variorum.sqlite`. A Terminal process reaching another app's container may
  meet macOS's "access data from other apps" prompt — hers to answer at the mint.

## Decisions and readings (PROVISIONAL where marked)

*(filled per piece — see below)*

## Verification

*(PENDING — filled when the suites and the rehearsal run)*
