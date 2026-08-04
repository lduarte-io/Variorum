# BIP-39 English wordlist — vendored (Phase 14b, R-5)

Provenance record for the BIP-39 English wordlist used by
`VariorumCore/Crypto/RecoveryPhrase` (the 12-word recovery phrase — Phase
14b ruling R-5, "12-word BIP-39 (Recommended)").

The wordlist file itself lives at
**`Sources/VariorumCore/Resources/bip39-english.txt`** — it must sit inside
the `VariorumCore` target directory to ship as a bundled SPM package
resource (`Bundle.module`), so this README records its provenance from the
`Vendor/` side rather than housing the file.

- **Upstream:** https://github.com/bitcoin/bips — `bip-0039/english.txt`
- **Pinned upstream commit:** `e7263a4cfe500c89e4269889244606953691ca33`
  (fetched 2026-08-04 via
  `raw.githubusercontent.com/bitcoin/bips/<commit>/bip-0039/english.txt`;
  byte-verbatim, zero local modifications)
- **SHA-256:** `2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda`
  — matches the canonical published hash of the BIP-39 English wordlist.
- **Shape:** 2048 words, one per line, LF-terminated, lowercase ASCII,
  alphabetically sorted; first word `abandon`, last word `zoo`.
- **License:** the BIP-0039 document is licensed PD/BSD-2-Clause per its
  preamble; the wordlist is treated as public-domain reference data across
  every BIP-39 implementation.

## Verification

`Tests/VariorumCoreTests/RecoveryPhraseTests.swift` pins the bundled
resource's SHA-256 to the hash above, its count to 2048, and its shape
(sorted, lowercase, unique) — a corrupted or swapped wordlist fails the
suite, never silently derives wrong phrases. Do not touch the resource file
except to re-vendor at a newer pinned commit — and then update this
README's pin in the same commit.
