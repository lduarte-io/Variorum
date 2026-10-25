//
//  PairCheckDoorTests.swift
//  VariorumTests — VX-529 unit 2, scope 4 (`notes/plans/fixes/vx-529-pair-catchup.md`): THE CHECK DOOR in the pair
//  catch-up's states — still a READ, its contract literal ("Checking changes nothing"). Over planted leaves (no keychain,
//  no network; headless in the implementer's SwiftPM harness too).
//    - the catch-up's state: the fourth answer ("…doesn't open this library, but it opens your account.") gains the road's
//      pointer (`SecretCheckRoadTests.theHonestSplitWhenTheAccountsSecretsChangedElsewhere`, flipped deliberately, pins it);
//    - E6 (a synced library with no passphrase lock of its own): the account's passphrase says the why and the road
//      (R-529-6) — and NOTHING is written: the heal is never the check's (P-VX529-4).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 2 — the check door in the pair catch-up's states (planted, read-only)")
@MainActor
struct PairCheckDoorTests {
    typealias Account = PlantedAccount
    typealias Plant = SecretCheckPlant

    /// E6: the account's passphrase over a library joined by its words — the why and the road; no lock lands; nothing at
    /// all written. A passphrase that is no one's keeps the plain refusal.
    @Test func e6_theAccountsPassphraseSaysWhyAndWritesNothing() async throws {
        let world = try await LobbyVaultRoadTests.e6Joined()
        let session = world.session
        let before = try Plant.untouched(world.road, session, vault: world.vault, keys: world.keys)
        let logs = Plant.writeLogs(world.road, vault: world.vault)
        let typed = await ProtectionSecretCheck.check(session, typed: Account.passphrase, signIn: Account.signedIn)
        #expect(typed == .doesNotOpen(.passphrase, opensAccount: true, because: .notTypedHereYet))
        #expect(typed.lines == [ProtectionWords.checkSecretsAccountPassphraseNotTypedHere] && typed.warns)
        let nobodys = await ProtectionSecretCheck.check(session, typed: "no one's passphrase", signIn: Account.signedIn)
        #expect(nobodys == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(nobodys.lines == [ProtectionWords.passphraseDoesNotOpen])
        let words = await ProtectionSecretCheck.check(session, typed: world.words.joined(separator: " "),
                                                      signIn: Account.signedIn)
        #expect(words == .opens(.words, account: .opens), "the words open both")
        #expect(Plant.writeLogs(world.road, vault: world.vault) == logs, "no write of any kind")
        #expect(try Plant.untouched(world.road, session, vault: world.vault, keys: world.keys) == before,
                "every item and every byte unchanged — the lock never lands here")
        #expect(session.library.keyFile?.passphrase == nil)
    }

    /// The pointer is said only in the catch-up's state: the account's secret over a library that is NOT behind (another
    /// account's words — a guard) says the plain fourth answer, no pointer.
    @Test func thePointerOnlyInTheCatchUpsState() {
        #expect(SecretCheckOutcome.doesNotOpen(.words, opensAccount: true).lines
            == [ProtectionWords.checkSecretsOpensAccountNotLibrary(.words)])
        #expect(SecretCheckOutcome.doesNotOpen(.words, opensAccount: true, because: .catchUpOwed).lines
            == [ProtectionWords.checkSecretsOpensAccountNotLibrary(.words), ProtectionWords.checkSecretsCatchUpPointer])
        for line in [ProtectionWords.checkSecretsCatchUpPointer, ProtectionWords.checkSecretsAccountPassphraseNotTypedHere] {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { $0.count > 1 && $0 == $0.uppercased() }
            #expect(shouting.isEmpty, "\(line)")
        }
    }
}
