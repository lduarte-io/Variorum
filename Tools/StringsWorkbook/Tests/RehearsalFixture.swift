// BRANCH-ONLY tests (`tools/strings-workbook`; never merges).

import Foundation
import Testing
@testable import StringsWorkbook
import VariorumCore

/// OPT-IN (skipped unless `STRINGS_WORKBOOK_REHEARSAL_DIR` names a folder):
/// writes a scratch library laid out exactly like hers — an ENCRYPTED store,
/// its key file beside it with a passphrase wrap at PRODUCTION KDF parameters
/// (v1 — the CLI is not a test host, so the production floor applies) and a
/// recovery-words wrap, some existing books and notes — plus the throwaway
/// `passphrase.txt` / `words.txt` the rehearsal feeds the CLI. Refuses any
/// folder inside an app container.
@Suite("StringsWorkbook — the CLI rehearsal fixture (opt-in)")
struct RehearsalFixture {
    static let folder = ProcessInfo.processInfo.environment["STRINGS_WORKBOOK_REHEARSAL_DIR"]

    @Test(.enabled(if: folder != nil)) func writeAScratchLibraryLikeHers() throws {
        let parent = URL(fileURLWithPath: try #require(Self.folder))
        #expect(!parent.path.contains("/Library/Containers/"))
        guard !parent.path.contains("/Library/Containers/") else { return }
        try? FileManager.default.removeItem(at: parent)
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

        let passphrase = "rehearsal only \(UUID().uuidString.prefix(8)) — not hers"
        let words = try RecoveryPhrase.generate()
        let library = try ScratchLibrary.make(
            in: parent.appendingPathComponent("library", isDirectory: true),
            passphrase: passphrase, words: words,
            kdf: .v1(salt: PassphraseKDF.randomSalt())
        ) { ops in
            let novel = try ops.createReading(name: "Her novel", kind: .book)
            for title in ["chapter one", "chapter two"] {
                let post = try ops.createPost(title: title)
                try ops.addPostToReading(post.id, to: novel.id)
                _ = try ops.newBlock(in: post.id, text: "Some of her prose in \(title).")
            }
            let loose = try ops.createPost(title: "a loose note")
            _ = try ops.newBlock(in: loose.id, text: "Pool text.")
        }
        try Data(passphrase.utf8).write(to: parent.appendingPathComponent("passphrase.txt"))
        try Data(words.joined(separator: " ").utf8).write(to: parent.appendingPathComponent("words.txt"))
        #expect(StoreFilePresence.classify(at: library.storeURL) == .encryptedOrUnknown)
        #expect(try StoreUnlock.localRoads(besideStore: library.storeURL).passphrase)
    }
}
