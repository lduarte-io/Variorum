// BRANCH-ONLY tests (`tools/strings-workbook`; never merges). Scratch stores
// only — no test here touches the Keychain, the dev store or her library.

import Foundation
@testable import StringsWorkbook
import VariorumCore

enum Repo {
    /// Tools/StringsWorkbook/Tests/Support.swift → the repo root.
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
    static let stringsDoc = root.appendingPathComponent("notes/copy-pass/all-user-facing-strings.md")
    static let priorityDoc = root.appendingPathComponent("notes/copy-pass/priority-order.md")

    static func text(_ url: URL) throws -> String { try String(contentsOf: url, encoding: .utf8) }
}

/// The real docs, parsed once per process.
enum RealDocs {
    static let inventory: StringsInventory = {
        try! StringsInventory.parse(try! Repo.text(Repo.stringsDoc))
    }()
    static let tiers: [TierPlan.Tier] = {
        try! TierPlan.tiers(fromPriorityDoc: try! Repo.text(Repo.priorityDoc))
    }()
    static let plan: WorkbookPlan = {
        try! WorkbookPlan.make(inventory: inventory, tiers: tiers)
    }()

    static var bullets: [StringsInventory.Bullet] { inventory.surfaces.flatMap(\.bullets) }

    /// The one bullet whose FIRST site is `site`.
    static func bullet(firstSite site: String) -> StringsInventory.Bullet? {
        bullets.first { $0.sites.first == site }
    }
}

/// A scratch library laid out exactly like hers: an ENCRYPTED store with its
/// key file (`variorum-keys-<fp>.json`) beside it, optionally carrying a
/// passphrase wrap and/or a recovery-words wrap. Custody is in-memory only.
struct ScratchLibrary {
    let folder: URL
    let storeURL: URL
    let key: StoreKey

    /// Fast KDF parameters — legal only under the test host's relaxed floor
    /// (`PassphraseKDF.floor`); the CLI rehearsal fixture uses production v1.
    static func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    static func make(
        in parent: URL? = nil,
        passphrase: String? = nil,
        words: [String]? = nil,
        kdf: PassphraseKDF.Descriptor = fastKDF(),
        seed: ((Operations) throws -> Void)? = nil
    ) throws -> ScratchLibrary {
        let folder = parent ?? FileManager.default.temporaryDirectory
            .appendingPathComponent("strings-workbook-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let storeURL = folder.appendingPathComponent("variorum.sqlite")
        let key = StoreKey.mint()
        // The mint road's order: the key file (store id + fingerprint) first,
        // then the encrypted store born under the key.
        _ = try StoreIdentity.establish(besideStore: storeURL, key: key)
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        let (view, binding) = database.asRebindable()
        if let seed { try WorkbookMint.withOperations(on: view, seed) }
        _ = binding.lock()

        if passphrase != nil || words != nil {
            guard var envelope = try StoreKeyEnvelope.loadCurrent(besideStore: storeURL) else {
                throw ScratchError.noEnvelope
            }
            if let passphrase { try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: kdf) }
            if let words { try envelope.setRecoveryWrap(key: key, words: words) }
            try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        }
        return ScratchLibrary(folder: folder, storeURL: storeURL, key: key)
    }

    func remove() { try? FileManager.default.removeItem(at: folder) }

    enum ScratchError: Error { case noEnvelope }
}
