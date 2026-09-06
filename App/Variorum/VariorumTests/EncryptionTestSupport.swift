//
//  EncryptionTestSupport.swift
//  VariorumTests
//
//  pre-13x batch 3a — the app's SETUP door takes the twelve words (copy §2a;
//  the postures design decision 5: a vault is never born without its recovery
//  wrap), so the 14b-era pins that set a vault up "passphrase only" call
//  this convenience: the REAL road, with words generated here and handed
//  back. A convenience over the production door — never a second road.
//

import Foundation
import VariorumCore
@testable import Variorum

extension EncryptionSession {
    /// The production `setUp(passphrase:recoveryWords:)` with fresh words;
    /// returns the words it landed (the vault's recovery wrap is under them).
    @discardableResult
    func setUp(passphrase: String) async -> [String] {
        let words = (try? RecoveryPhrase.generate()) ?? []
        await setUp(passphrase: passphrase, recoveryWords: words)
        return words
    }
}
