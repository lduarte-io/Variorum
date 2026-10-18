//
//  SystemIDsLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `IDsLeaf` (`Executor/Leaves.swift`): every random thing the executor mints,
//  from CryptoKit's CSPRNG — the existing mints, never a second road: `StoreKey.mint()` (a random 32-byte
//  library key), `AppleKeyMaterial.mint()`, a fresh `PassphraseKDF.Descriptor.v1` over
//  `PassphraseKDF.randomSalt()` (the descriptor today's envelope mints), and the twelve words from
//  `RecoveryPhrase.generate()` (BIP-39 — the same word list the envelope's recovery phrase uses). IDs are
//  plain random UUIDs, lowercased (rule 23 — no hardware fingerprinting).
//

import CryptoKit
import Foundation
import VariorumCore

nonisolated final class SystemIDsLeaf: IDsLeaf, @unchecked Sendable {
    func mintID() -> String { UUID().uuidString.lowercased() }
    func mintLibraryKey() -> StoreKey { StoreKey.mint() }
    func mintAppleKey() -> AppleKeyMaterial { AppleKeyMaterial.mint() }
    func mintSymmetricKey() -> SymmetricKey { SymmetricKey(size: .bits256) }
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor { .v1(salt: PassphraseKDF.randomSalt()) }

    /// The word list failing to load yields no words — and a creation with no words REFUSES (its words lock
    /// cannot be derived), never a library without its secret (rule 2).
    func mintWords() -> [String] { (try? RecoveryPhrase.generate()) ?? [] }
}
