import CryptoKit
import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 3 (L9's machinery) — the enrollment state machine over
/// the scripted vault server: setup, both enrollment roads, the recovery
/// wrap's (RE)GENERATE arms, change-passphrase both authorizations, and
/// every refusal arm the flows word (wrong passphrase, checksum-failing
/// phrase, vault-absent, vault-newer-format).
@Suite("Vault enrollment flows (Phase 14b, L9)")
struct VaultEnrollmentTests {

    // MARK: Setup

    @Test func setUpCreatesAPassphraseOnlyVaultAndReturnsWorkingMaterial() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        // Round 5: the overnight vault carries the passphrase wrap ALONE.
        let vault = try await world.client.fetchVault()
        #expect(vault != nil)
        #expect(vault?.masterWrappedByRecovery == nil)
        // The material's keys match what a fresh enrollment unwraps.
        let enrolled = try await world.enrollment.enroll(passphrase: "orchard-lantern-13")
        #expect(enrolled == material)
        // Distinct per-class keys with lowercase-UUID ids.
        #expect(material.corpusKey != material.journalBridgeKey)
        #expect(material.corpusKeyID != material.journalBridgeKeyID)
        #expect(UUID(uuidString: material.corpusKeyID) != nil)
    }

    @Test func setUpRefusesWhenAVaultAlreadyExists() async throws {
        let world = VaultTestWorld()
        _ = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        await #expect(throws: KeyVaultClientError.vaultAlreadyExists) {
            _ = try await world.enrollment.setUp(passphrase: "another-passphrase")
        }
    }

    @Test func setUpRefusesAnEmptyPassphrase() async throws {
        let world = VaultTestWorld()
        await #expect(throws: VaultEnrollmentError.emptyPassphrase) {
            _ = try await world.enrollment.setUp(passphrase: "")
        }
        #expect(world.server.isEmpty)
    }

    // MARK: Enrollment (R-4: passphrase entry)

    @Test func aWrongPassphraseSpeaksAndNeverYieldsMaterial() async throws {
        let world = VaultTestWorld()
        _ = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await world.enrollment.enroll(passphrase: "orchard-lantern-14")
        }
    }

    @Test func enrollmentWithNoVaultSpeaksVaultAbsent() async throws {
        let world = VaultTestWorld()
        await #expect(throws: KeyVaultClientError.vaultAbsent) {
            _ = try await world.enrollment.enroll(passphrase: "orchard-lantern-13")
        }
    }

    @Test func enrollmentAgainstANewerFormatVaultRefusesByVersion() async throws {
        let world = VaultTestWorld()
        _ = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        var row = world.server.storedRow(userID: world.userID)!
        row.formatVersion = KeyVaultFormat.currentFormatVersion + 1
        world.server.store(row)
        await #expect(throws: KeyVaultClientError.unsupportedFormatVersion(
            KeyVaultFormat.currentFormatVersion + 1)
        ) {
            _ = try await world.enrollment.enroll(passphrase: "orchard-lantern-13")
        }
    }

    @Test func theKDFMeasurementReportsEveryDerivation() async throws {
        let world = VaultTestWorld()
        let measurements = LockIsolated<[TimeInterval]>([])
        var enrollment = world.enrollment
        enrollment.kdfMeasurement = { seconds in
            measurements.withValue { $0.append(seconds) }
        }
        _ = try await enrollment.setUp(passphrase: "orchard-lantern-13")
        _ = try await enrollment.enroll(passphrase: "orchard-lantern-13")
        #expect(measurements.value.count == 2, "setup + enrollment each derive once")
        #expect(measurements.value.allSatisfy { $0 > 0 })
    }

    // MARK: The recovery wrap ((RE)GENERATE — Rounds 5 + 7)

    @Test func landingTheRecoveryWrapEnablesThePhraseRoad() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        #expect(try await world.enrollment.hasRecoveryWrap() == false)

        // The phrase road refuses while the wrap is absent (the Round-5
        // overnight state).
        let words = try RecoveryPhrase.generate()
        await #expect(throws: KeyVaultError.recoveryWrapAbsent) {
            _ = try await world.enrollment.enroll(recoveryWords: words)
        }

        try await world.enrollment.landRecoveryWrap(words: words, material: material)
        #expect(try await world.enrollment.hasRecoveryWrap() == true)

        // The WRITTEN PHRASE alone unwraps everything (the disaster road —
        // the restore drill's mechanics, gate step 6).
        let recovered = try await world.enrollment.enroll(recoveryWords: words)
        #expect(recovered == material)
    }

    @Test func replacingAnExistingWrapRequiresTheDeliberateConfirm() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let first = try RecoveryPhrase.generate()
        try await world.enrollment.landRecoveryWrap(words: first, material: material)

        // Without allowReplace the batch-1 refusal stands.
        let second = try RecoveryPhrase.generate()
        await #expect(throws: KeyVaultError.recoveryWrapAlreadyPresent) {
            try await world.enrollment.landRecoveryWrap(words: second, material: material)
        }

        // The deliberate replace: the NEW phrase works, the OLD one dies.
        try await world.enrollment.landRecoveryWrap(
            words: second, material: material, allowReplace: true)
        let recovered = try await world.enrollment.enroll(recoveryWords: second)
        #expect(recovered == material)
        await #expect(throws: VaultEnrollmentError.wrongRecoveryPhrase) {
            _ = try await world.enrollment.enroll(recoveryWords: first)
        }
    }

    @Test func aChecksumFailingPhraseSpeaksBeforeAnyServerContact() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        // Twelve valid words whose checksum deterministically fails: the
        // all-zero-entropy phrase's valid last word is "about", so twelve
        // "abandon"s always trip the checksum (never flaky — every word is
        // in the list, only the checksum refuses).
        let words = Array(repeating: "abandon", count: 12)
        let requestsBefore = world.server.requestCount
        await #expect(throws: RecoveryPhraseError.checksumMismatch) {
            try await world.enrollment.landRecoveryWrap(words: words, material: material)
        }
        #expect(world.server.requestCount == requestsBefore,
                "phrase validation refuses before any server contact")
    }

    // MARK: Change passphrase (Round 7's scope addition)

    @Test func changeByCurrentPassphraseRewrapsAndLeavesRecoveryUntouched() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let words = try RecoveryPhrase.generate()
        try await world.enrollment.landRecoveryWrap(words: words, material: material)
        let saltBefore = (try await world.client.fetchVault())!.kdf.salt

        let returned = try await world.enrollment.changePassphrase(
            authorizedBy: .passphrase("orchard-lantern-13"),
            newPassphrase: "meadow-castle-77")

        // Old passphrase dead, new one live, keys identical (a one-key
        // re-wrap, never a corpus re-encrypt — R-7's soft door).
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await world.enrollment.enroll(passphrase: "orchard-lantern-13")
        }
        let enrolled = try await world.enrollment.enroll(passphrase: "meadow-castle-77")
        #expect(enrolled == material)
        #expect(returned == material)
        // The recovery words are UNCHANGED by a passphrase change.
        let viaPhrase = try await world.enrollment.enroll(recoveryWords: words)
        #expect(viaPhrase == material)
        // A fresh salt + descriptor was minted for the new wrap.
        let saltAfter = (try await world.client.fetchVault())!.kdf.salt
        #expect(saltAfter != saltBefore)
    }

    @Test func changeByRecoveryPhraseIsTheForgotPassphraseRoad() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let words = try RecoveryPhrase.generate()
        try await world.enrollment.landRecoveryWrap(words: words, material: material)

        let returned = try await world.enrollment.changePassphrase(
            authorizedBy: .recoveryPhrase(words),
            newPassphrase: "harbor-signal-42")

        #expect(returned == material, "the recovery road both fixes and enrolls")
        let enrolled = try await world.enrollment.enroll(passphrase: "harbor-signal-42")
        #expect(enrolled == material)
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await world.enrollment.enroll(passphrase: "orchard-lantern-13")
        }
    }

    @Test func changeAuthorizedByAWrongRoadRefusesWithoutWriting() async throws {
        let world = VaultTestWorld()
        _ = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let vaultBefore = try await world.client.fetchVault()
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await world.enrollment.changePassphrase(
                authorizedBy: .passphrase("wrong"), newPassphrase: "meadow-castle-77")
        }
        let vaultAfter = try await world.client.fetchVault()
        #expect(vaultAfter == vaultBefore, "a refused change writes nothing")
    }
}
