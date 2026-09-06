//
//  MobileEncryptionTestSupport.swift
//  VariorumMobileTests
//
//  pre-13x batch 3a — the phone's copy of the Mac suite's convenience: the
//  app's SETUP door takes the twelve words (copy §2a; decision 5), so the
//  14b-era pins call the REAL road with words generated here.
//

import Foundation
import VariorumCore
@testable import VariorumMobile

extension EncryptionSession {
    @discardableResult
    func setUp(passphrase: String) async -> [String] {
        let words = (try? RecoveryPhrase.generate()) ?? []
        await setUp(passphrase: passphrase, recoveryWords: words)
        return words
    }
}
